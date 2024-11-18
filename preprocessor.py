import pandas as pd


def preprocess(df, region_df):
    # Fiter for summer olympics
    df = df[df['Season'] == 'Summer']
    # meging df and region_df
    df = df.merge(region_df, on='NOC', how='left')
    # remove duplicates
    df.drop_duplicates(inplace=True)
    # one hot code medals column
    dummy = pd.get_dummies(df['Medal'])
    dummy = dummy.astype(int)
    df = pd.concat([df, dummy], axis=1)

    return df