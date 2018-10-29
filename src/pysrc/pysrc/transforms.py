# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


from datetime import datetime
from dateutil.parser import parse as timeParse
import pdb
#import pytz

def time_to_str(x):
    '''Converts datetime object x to a string format'''
    return x.strftime('%Y-%m-%d %H:%M:%S')

def standardize_datetime(x):
    ''' Converts any date string/float/int to '%Y-%m-%d %H:%M:%S' string format.
    
    Details:  Time zones are a mess. Unix time stamps should be UTC date times, 
        but time zones are generally unknown for string-formatted times.    
        
        Even if we knew time zones, note that SQLite doesn't handle timezones well:  
            http://stackoverflow.com/a/13321766/2232265
    '''
    if isinstance(x, float) | isinstance(x, int):
        if x == x: # else, x = nan #.replace(tzinfo=pytz.utc)
            return time_to_str(datetime.utcfromtimestamp(x))
        else:
            return None
    elif not x:
        return None
    else:
        #         try:
        #             out = time_to_str(timeParse(x))
        #         except:
        #             pdb.set_trace()
        #             print 'print x'
        return time_to_str(timeParse(x)) # out

# Standardize a time variable:
# df[tv] = df[tv].apply(standardize_datetime)
