from statistics import median, mean, stdev

# CUSTOMER TRANSACION ANALYSER
def analyse_transactions(*transactions, **options):
    avg_request = options.get("average", False)
    total_request = options.get("total", False)
    max_request = options.get("maximum", False)
    min_request = options.get("minimum", False)
    all_requested = {}

    if avg_request:
        avg_value = sum(transactions) / len(transactions)
        all_requested["average"] = round(avg_value, 2)
    if total_request:
        total_value = sum(transactions)
        all_requested["total"] = total_value
    if max_request:
            max_value = max(transactions)
            all_requested["maximum"] = max_value
    if min_request:
            min_value = min(transactions)
            all_requested["minimum"] = min_value

    final_values = ""
    if len(all_requested) == 0:
        final_values = "No transaction requests have been made."
    else:
        for key, value in all_requested.items():
            final_values += f"{key}: {value}\n"

    return final_values
#transactions = [1, 2, 3, 4, 5]
#print(analyse_transactions(*transactions, average=True, total=True))

# DATA CLEANING FUNCTION
def clean_values(*values, **options):
    cleaned = list(values)

    if options.get("remove_none", False):
        cleaned = list(x for x in cleaned if x is not None)
    if options.get("remove_negative", False):
       cleaned = list(x for x in cleaned if (x  is None) or (x >= 0))
    if options.get("remove_duplicates", False):
        cleaned = list(set(cleaned))
    if options.get("sort", False):
        cleaned.sort(key=lambda x: x is not None)
    return cleaned
    # simplified implementation dramatically, not most efficient at all
    # but it works :)
    # took me longer than it should have by a country mile
"""print(clean_values(
    10, None, 20, -5, 20, 30,
    remove_none=True,
    remove_negative=True,
    remove_duplicates=True,
    sort=True
))"""

# ANALYSE DATASET
def analyse_dataset(*values, **options):
    list_values = list(values)
    operations = {
        "total": lambda x: sum(x),
        "average": lambda x: round(sum(x) / len(x), 2),
        "median": lambda x: median(x),
        "minimum": lambda x: min(x),
        "maximum": lambda x: max(x),
        "unique": lambda x: list(set(x)),
        "sort": lambda x: sorted(x)
    }

    results = {
        name: func(list_values)
        for name, func in operations.items()
        if options.get(name, False)
    }

    if not results:
        return "No evaluations have been made"

    return "\n".join(f"{k}: {v}" for k, v in results.items())
        
    """if options.get("total", False): 
        total = sum(values)
    if options.get("average", False):
        avg = round(sum(values) / len(values), 2)
    if options.get("average", False):
        median = sum(values) / len(values)
    if options.get("minimum", False):
        min = min(values)
    if options.get("maximum", False):
        max = max(values)
    if options.get("unique", False):
        unique = list(x for x in values if values.count(x) > 1)
    if options.get("sort", False):
        values.sort()"""
    # i think i should change this to a dictionary with functions for each value
data = [12, 15, 18, 21, 15, 30, 42, 18, 25]
"""print(analyse_dataset(
    *data,
    total=True, 
    average=True,
    median=True, 
    minimum=True, 
    maximum=True, 
    unique=True, 
    sort=True 
    ))"""

# FUNCTION-BASED DATA PIPELINE
def process_data(data, *operations):
    """calculations = {
        remove_negatives: lambda x: remove_negatives(x),
        square_values: lambda x: square_values(x),
        sort_values: lambda x: sort_values(x)
    }

    processed_data = data
    for func, wrapper in calculations.items():
        if func in operations:
            processed_data = wrapper(processed_data)"""
    # i am fully aware that my version above is extremely double winded
    # noticed it when i saw the function itself was in the operations tuple and not a string

    processed_data = data
    for operation in operations:
        processed_data = operation(processed_data)

    return processed_data

def remove_negatives(data):
    return [x for x in data if x >= 0]

def square_values(data):
    return [x**2 for x in data]

def sort_values(data):
    return sorted(data)

"""result = process_data(
    [-4, 3, -2, 7, 1],
    remove_negatives,
    square_values,
    sort_values
)
print(result)"""

# CUSTOM FILTER AND TRANSFORM
def transform_data(data, filter_func=None, transform_func=None):
    transformed_data = data

    for num in transformed_data:
        if filter_func(num) == False and filter_func is not None:
            transformed_data.remove(num)

    transformed_data = [transform_func(num) 
                        for num in transformed_data 
                        if transform_func is not None]
    
    return transformed_data

"""numbers = [1, 2, 3, 4, 5, 6]

result = transform_data(
    numbers,
    filter_func=lambda x: x % 2 == 0,
    transform_func=lambda x: x ** 2
)
print(result)"""

def generate_report(sales, **options):
    # compute single aggregates
    revenue = sum(s["price"] * s["quantity"] for s in sales)
    average = round(revenue / len(sales), 2)
    category_summary = {s["category"] for s in sales}

    highest_price = max(sales, key= lambda s: s["price"])["price"]
    best_product = [s["product"] for s in sales if s["price"] == highest_price]

    calculations = {
        "revenue": lambda: revenue,
        "average_order": lambda: average,
        "category_summary": lambda: category_summary,
        "best_product": lambda: best_product
    }

    return {
        name: func()
        for name, func in calculations.items()
        if options.get(name, False)
    }
    
"""sales = [
    {"product": "Laptop", "category": "Tech", "price": 800, "quantity": 2},
    {"product": "Mouse", "category": "Tech", "price": 25, "quantity": 10},
    {"product": "Desk", "category": "Furniture", "price": 200, "quantity": 3},
]
print(generate_report(
    sales,
    revenue=True,
    category_summary=True,
    best_product=True,
    average_order=True
))"""

# MINI DATA ANALYSIS FRAMEWORK
#def analyse_dataset(data, *operations, **options):

data = [12, 15, 18, 21, 25, 30, 31, 40, 200]

def sort_data(data):
    return sorted(data)

def remove_outliers(data):
    m = mean(data)
    s = stdev(data)
    # attempting z scores
    return [x for x in data if abs((x- m)/ s <= 3)]
    
print(remove_outliers(data))