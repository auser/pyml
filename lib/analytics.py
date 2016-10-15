import json
import pandas as pd
import googleanalytics as ga
# import lib.ga_utils as ga

class Analytics():
  """Analytics helper"""
  def __init__(self, credentials, **kwargs):
    self.credentials = credentials
    self.accounts = ga.authenticate(
      access_token=credentials.access_token,
      client_id=credentials.client_id,
      client_secret=credentials.client_secret,
      refresh_token=credentials.refresh_token)
    self.kwargs = kwargs

  def query_ga(self, profile_id, **kwargs):
    return ga.ga_to_df(self.service.data().ga().get(
        ids='ga:' + profile_id,
        start_date='7daysAgo',
        end_date='today',
        metrics='ga:sessions,ga:bounceRate',
        dimensions='ga:date'
      ).execute())

  def account(self, account_name):
    return self.accounts[account_name]
  
  def get_prop(self, account_name, property_name):
    return self.account(account_name).webproperties[property_name]