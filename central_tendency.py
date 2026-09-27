import pandas as pd

# Starting off with some mean,median and mode

data = pd.Series([4, 2, 12, 26, 8])
mean = data.mean()
median = data.median()
mode = data.mode()
std = data.std()
var = data.var()

print(var)