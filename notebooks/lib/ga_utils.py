import json
import pandas as pd
import lib.auth as auth

# def get_example(profile_id):
# 	"""Example query based on id column from list_profiles()"""
# 	return ga_to_df(service.data().ga().get(
# 		ids='ga:' + profile_id,
# 		start_date='7daysAgo',
# 		end_date='today',
# 		metrics='ga:sessions,ga:bounceRate',
# 		dimensions='ga:date'
# 	).execute())

def ga_to_df(d):
	"""Take a resp json from GA and transform to pandas DF """
	columns = [x['name'] for x in d['columnHeaders']]
	rows = [x for x in d['rows']]
	return pd.DataFrame(rows, columns=columns)

def raw_query(profile_id, start_date, end_date,metrics,dimensions):
	""" Utility method to make raw query """
	return service.data().ga().get(
		ids='ga:' + profile_id,
		start_date=start_date,
		end_date=end_date,
		metrics=metrics,
		dimensions=dimensions
	).execute()