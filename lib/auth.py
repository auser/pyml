"""A simple example of how to access the Google Analytics API."""

import argparse

import apiclient
from apiclient.discovery import build
import httplib2
from oauth2client import client, file, tools
from lib.analytics import Analytics

APPLICATION_NAME = 'jupyter experiments'

class Auth():
  """Create an auth client"""
  def __init__(self, app_name, **kwargs):
    super(Auth, self).__init__()
    self.app_name = app_name
    self.kwargs = kwargs
    self.client_secrets_path = kwargs.get('client_secrets', './client_secrets.json')

  def get_analytics(self, **kwargs):
    credentials = self.get_credentials(['https://www.googleapis.com/auth/analytics.readonly'])
    return Analytics(credentials, **kwargs)

  def get_service(self, api_name, api_version, scopes):
    credentials = self.get_credentials(scopes)
    http = credentials.authorize(http=httplib2.Http())
    service = build(api_name, api_version, http=http)
    return service

  def stored_credentials(self):
    return self.get_store().get()

  def get_credentials(self, scopes):
    credentials = self.stored_credentials()
    if not credentials or credentials.invalid:
      flow = client.flow_from_clientsecrets(
                self.client_secrets_path, scope=scopes,
                message=tools.message_if_missing(self.client_secrets_path))

      flow.user_agent = self.app_name
      flags = self.get_flags()
      store = self.get_store()
      if flags:
        credentials = tools.run_flow(flow, store, flags)
      else:
        credentials = tools.run(flow, store)
      print("Storing credentials at " + self.credential_path())
    return credentials

  def get_flags(self):
    try:
      import argparse
      parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        parents=[tools.argparser])
      flags = parser.parse_args(['--noauth_local_webserver'])
    except ImportError:
      flags = None
    print(flags)
    return flags

  def get_store(self):
    return file.Storage(self.credential_path())

  def credential_path(self):
    return self.app_name + '.dat'
    # home_dir = os.path.expanduser('~')
    # credential_dir = os.path.join(home_dir, '.credentials')
    # if not os.path.exists(credential_dir):
    #     os.makedirs(credential_dir)
    # credential_path = os.path.join(credential_dir, self.api_name + '.json')

# def get_service(api_name, api_version, scope, redirect_uri, client_secrets_path):
#   """Get a service that communicates to a Google API.
#   Args:
#     api_name: string The name of the api to connect to.
#     api_version: string The api version to connect to.
#     scope: A list of strings representing the auth scopes to authorize for the
#       connection.
#     client_secrets_path: string A path to a valid client secrets file.
#   Returns:
#     A service that is connected to the specified API.
#   """
#   # Parse command-line arguments.
#   parser = argparse.ArgumentParser(
#       formatter_class=argparse.RawDescriptionHelpFormatter,
#       parents=[tools.argparser])
#   flags = parser.parse_args([])

#   # Set up a Flow object to be used if we need to authenticate.
#   flow = client.flow_from_clientsecrets(
#         client_secrets_path, 
#         scope=scope, 
#         redirect_uri=redirect_uri,
#         message=tools.message_if_missing(client_secrets_path))
#   flow.user_agent = APPLICATION_NAME

#   # Prepare credentials, and authorize HTTP object with them.
#   # If the credentials don't exist or are invalid run through the native client
#   # flow. The Storage object will ensure that if successful the good
#   # credentials will get written back to a file.
#   storage = file.Storage(api_name + '.dat')
#   credentials = storage.get()
#   if credentials is None or credentials.invalid:
#     credentials = tools.run_flow(flow, storage, flags)
#   http = credentials.authorize(http=httplib2.Http())

#   # Build the service object.
#   service = build(api_name, api_version, http=http)

#   return service

# def main():
#   # Define the auth scopes to request.
#   scope = ['https://www.googleapis.com/auth/analytics.readonly']
#   redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
  
#   # Authenticate and construct service.
#   service = get_service('analytics', 'v3', scope, redirect_uri, 'client_secrets.json')
#   return service

# if __name__ == '__main__':
#   main()