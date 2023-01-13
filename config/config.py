#Use Package Handler before importing
#some libs/modules might be dead, feel free to delete
#import libs
import urllib.request, urllib.parse, urllib.error
import os, msal

from urllib.parse import quote_plus

import pandas as pd
pd.options.mode.chained_assignment = None  # default='warn'
pd.set_option("display.precision", 8)

import math
from datetime import (timedelta, datetime)

import pyodbc
from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String

#debug
# test_drivers = pyodbc.drivers()
# print(test_drivers)

class presencepbi(object):
    #variables
    CLIENT_SECRET = "_rtJ_frV3WwF1J1HaWK~1iBM6hn5K_E_p2"
    AUTHORITY = "https://login.microsoftonline.com/4e99d104-87a6-40ae-8935-c56dcb631746" 
    CLIENT_APPLICATION_ID = "0461f36f-58f2-4f2b-825f-bdfcfa78db56"

    app = msal.ConfidentialClientApplication(
        client_id=CLIENT_APPLICATION_ID,
        authority=AUTHORITY,
        app_name='DataServicesPBI',
        client_credential=CLIENT_SECRET
    )

    ACCOUNTS = app.acquire_token_for_client(scopes='https://graph.microsoft.com/.default')

    HEADERS = {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": ACCOUNTS['token_type'] + " " + ACCOUNTS['access_token']
        }

    #we care about groups
    base_group_url = 'https://graph.microsoft.com/v1.0/groups'

    #small chunks
    page_count = '100'

    #declare
    skip_token=None

class azuresql(object):
    server = 'MiddleEarth.database.windows.net'
    database = 'rohan'
    username ='Theoden@RohanIsInMiddleEarth.com'
    password = 'RidersOfRohan'
    Authentication='ActiveDirectoryPassword'
    driver= '{ODBC Driver 17 for SQL Server}'
    sqlconn = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=MiddleEarth.database.windows.net;DATABASE=rohan;UID=Theoden@RohanIsInMiddleEarth.com;PWD=RidersOfRohan;AUTHENTICATION=ActiveDirectoryPassword"
    quoted = quote_plus(sqlconn)
    newconn = 'mssql+pyodbc:///?odbc_connect={}'.format(quoted)
    engine = create_engine(newconn,fast_executemany=True,connect_args={'autocommit': True})#echo=True,
    engine.connect()
    
    #transact
    cnxn = pyodbc.connect('DRIVER='+driver+
                      ';SERVER='+server+
                      ';PORT=1433;DATABASE='+database+
                      ';UID='+username+
                      ';PWD='+password+
                      ';AUTHENTICATION='+Authentication
                      )
    cnxn.timeout = 0
    cnxn.autocommit = True
    cursor = cnxn.cursor()
    cursor.fast_executemany=True