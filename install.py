#!/usr/bin/python3
# Inicializa el usuario y la base de datos especificados en el archivo de configuración "config/database.yml"

from yaml import load, dump
from psycopg2.extensions import AsIs
import psycopg2,sys

class bstatus:
    OK = '\033[92m[OK]:\033[0m'
    ERROR = '\033[91m[ERROR]:\033[0m'
    WARNING = '\033[93m[WARNING]:\033[0m'

class runtimeParameters:
    configFile = 'config/database.yml'
    environment = 'production'

productionConfig = load(open(runtimeParameters.configFile))
connectionString = ''

# Establece una conexión local mediante sockets para crear el rol propietario de la nueva base de datos
try:
    with psycopg2.connect('') as conn:
        conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
        
        with conn.cursor() as cur:
            cur.execute("SELECT 1 FROM pg_roles WHERE rolname=%s", (productionConfig[runtimeParameters.environment]['username'],))

            if cur.rowcount==0:
                if 'username' in productionConfig[runtimeParameters.environment] and 'password' in productionConfig[runtimeParameters.environment]:
                    try:
                        cur.execute("CREATE USER %s WITH PASSWORD %s", (AsIs(productionConfig[runtimeParameters.environment]['username']),productionConfig[runtimeParameters.environment]['password']))

                        print ('%s ROLE `%s` created' % (bstatus.OK, AsIs(productionConfig[runtimeParameters.environment]['username'])))
                    except psycopg2.Error as error:
                        print (error.pgerror)
            else:
                print ('%s ROLE `%s` already exists' % (bstatus.WARNING, AsIs(productionConfig[runtimeParameters.environment]['username'])))

        with conn.cursor() as cur:
            cur.execute("SELECT 1 FROM pg_database WHERE datname=%s", (productionConfig[runtimeParameters.environment]['database'],))

            if cur.rowcount==0:
                if 'username' in productionConfig[runtimeParameters.environment] and 'database' in productionConfig[runtimeParameters.environment]:
                    try:
                        cur.execute("CREATE DATABASE %s OWNER %s", (AsIs(productionConfig[runtimeParameters.environment]['database']),AsIs(productionConfig[runtimeParameters.environment]['username'])))

                        print ('%s Database `%s` created with owner `%s`' % (bstatus.OK, AsIs(productionConfig[runtimeParameters.environment]['database']),AsIs(productionConfig[runtimeParameters.environment]['username'])))
                    except psycopg2.Error as error:
                        print (error.pgerror)
            else:
                print ('%s DATABASE `%s` already exists' % (bstatus.WARNING, AsIs(productionConfig[runtimeParameters.environment]['database'])))
    
except psycopg2.Error as e:
    print ('%s No se pudo establecer la conexión con la Base de Datos' % bstatus.ERROR)
    print ('TIP: Executa el comando como un usuario con permisos de administración en la DB.')
    sys.exit(1)

"""
if 'database' in productionConfig[runtimeParameters.environment]:
    connectionString += ' dbname=' + productionConfig[runtimeParameters.environment]['database'] 

if 'username' in productionConfig[runtimeParameters.environment]:
    connectionString += ' user=' + productionConfig[runtimeParameters.environment]['username'] 

if 'password' in productionConfig[runtimeParameters.environment]:
    connectionString += ' password=' + productionConfig[runtimeParameters.environment]['password'] 

if 'host' in productionConfig[runtimeParameters.environment]:
    connectionString += ' host=' + productionConfig[runtimeParameters.environment]['host'] 

if 'port' in productionConfig[runtimeParameters.environment]:
    connectionString += ' port=' + productionConfig[runtimeParameters.environment]['port'] 
"""
