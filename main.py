import os, msal, requests, json, pandas as pd

from config.config import presencepbi
from config.config import azuresql
from config import config

class dsaadwsql(object): 
    def import_table(self,df,schema,table):
        #transform
        try:
            
            chunk_size = 200 #orig was at 10000
            num_chunks = config.math.ceil(len(df) / chunk_size)

            for i in range(num_chunks):
                try:
                    
                    chunk_df = df[i*chunk_size:(i+1)*chunk_size]
                    chunk_df.to_sql(table, azuresql.engine, if_exists = 'append', chunksize = chunk_size, schema=schema, index=False)

                except Exception as e:
                    print('failed to import chunk_df to' + str(schema) + '.' + str(table) + ' ... {}'.format(e))
                    return False

            return True

        except Exception as e:
            print('failed to import df to' + str(schema) + '.' + str(table) + ' ... {}'.format(e))
            return False

    def truncate_table(self,schema,table):
        try:
            query = f'''TRUNCATE TABLE [{schema}].[{table}]'''
            # print(query)
            azuresql.cursor.execute(query)
            azuresql.cursor.commit()

        except Exception as e:
            results = 'failed to truncate ' + str(schema) + '.' + str(table) + ' ... {}'.format(e)
            print(results)

    def execute_stored_proc(self,schema,proc):
        try:
            query = f'''EXEC [{schema}].[{proc}]'''
            # print(query)
            azuresql.cursor.execute(query)
            azuresql.cursor.commit()

        except Exception as e:
            results = 'failed to execute ' + str(schema) + '.' + str(proc) + ' ... {}'.format(e)
            print(results)

class aad(object):
    CLIENT_SECRET = presencepbi.CLIENT_SECRET
    AUTHORITY = presencepbi.AUTHORITY
    CLIENT_APPLICATION_ID = presencepbi.CLIENT_APPLICATION_ID
    app = presencepbi.app
    ACCOUNTS = presencepbi.ACCOUNTS
    HEADERS = presencepbi.HEADERS
    base_group_url = presencepbi.base_group_url
    page_count = presencepbi.page_count
    skip_token=presencepbi.skip_token

    def get_group_members(self,group_list_pool):
        #prod
        group_list_pool = group_list_pool.split()
        group_list_group = group_list_pool[0]

        #intial pass
        group_request = requests.get(self.base_group_url+'/'+group_list_group+'/members?$top='+self.page_count,headers=self.HEADERS)
        groups_payload = json.loads(group_request.content)

        #check for pagination
        try:
            skip_token = groups_payload['@odata.nextLink']
        except:
            skip_token = None

        #create df initially
        df = pd.DataFrame.from_dict(groups_payload['value'])
        #add group id
        df['groupId'] = group_list_group
        df.groupId = df.groupId.astype(str)

        # print(str(len(df)))
        while skip_token != None:
            j=True
            group_list_group = group_list_pool[0]
            group_request = requests.get(self.base_group_url+'/'+group_list_group+'/members?$top='+self.page_count,headers=self.HEADERS)
            groups_payload = json.loads(group_request.content)

            #check for pagination
            try:
                skip_token = groups_payload['@odata.nextLink']
            except:
                skip_token = None

            if skip_token != None:

                while j != False:
                    group_request_skip = group_request = requests.get(skip_token,headers=self.HEADERS)
                    groups_payload = json.loads(group_request_skip.content) 

                    #check for pagination
                    try:
                        skip_token = groups_payload['@odata.nextLink']
                    except:
                        skip_token = None

                    #create page_df
                    page_df = pd.DataFrame.from_dict(groups_payload['value'])
                    #add group_id
                    page_df['groupId'] = group_list_group
                    page_df.groupId = page_df.groupId.astype(str)
                    #dont care about sort
                    df = pd.concat([df,page_df], sort = False)
                    #print(str(len(df)))
                    if skip_token == None: 
                        #break
                        page_df = None
                        j = False
                        del group_list_pool[0]
                        
            else:
                #create page_df
                page_df = pd.DataFrame.from_dict(groups_payload['value'])

                #add group_id
                page_df['groupId'] = group_list_group
                page_df.groupId = page_df.groupId.astype(str)

                #dont care about sort
                df = pd.concat([df,page_df],sort=False)
                page_df = None

                del group_list_pool[0]

        if df.empty != True:
            try:
                df = df[['id','displayName','givenName','jobTitle','mail','surname','userPrincipalName','groupId']] 
                result = True
            except:
                result = False
                return df, result
        else:
            result = False
        
        return df, result


    def get_groups(self):
        #intial pass
        group_request = requests.get(self.base_group_url+'?$top='+self.page_count,headers=self.HEADERS)
        groups_payload = json.loads(group_request.content)

        try:
            skip_token = groups_payload['@odata.nextLink']
        except:
            skip_token = None

        #create df initially
        df = pd.DataFrame.from_dict(groups_payload['value'])

        j=True

        while j != False:
            group_request_skip = group_request = requests.get(skip_token,headers=self.HEADERS)
            groups_payload = json.loads(group_request_skip.content) 

            try:
                skip_token = groups_payload['@odata.nextLink']
            except:
                skip_token = None

            #create page_df
            page_df = pd.DataFrame.from_dict(groups_payload['value'])
            df = pd.concat([df,page_df])

            if skip_token == None:

                #break
                page_df = None
                j = False

        df = df[['id','deletedDateTime','classification','createdDateTime','description','displayName',
        'expirationDateTime','isAssignableToRole','mail','mailEnabled','mailNickname','renewedDateTime',
        'securityEnabled','securityIdentifier','visibility']]

        group_list_pool_df = df[['id']]
        group_list_pool = group_list_pool_df['id'].values.tolist()
        return df, group_list_pool

dsaadwsql = dsaadwsql()
aad = aad()


df, group_list_pool = aad.get_groups()

dsaadwsql.truncate_table('etl','AAD_Groups')
dsaadwsql.import_table(df,'etl','AAD_Groups')
dsaadwsql.truncate_table('etl','AAD_GroupMembers')
for group in group_list_pool:
    df, result = aad.get_group_members(group)
    # print(str(len(df)))
    if df.empty != True and result == True:
        dsaadwsql.import_table(df,'etl','AAD_GroupMembers')
    
dsaadwsql.execute_stored_proc('dbo','MERGE_AAD_GroupMembers')

