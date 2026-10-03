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
    operations = {
        "remove_none": list(x for x in values if x is not None),
        "remove_negative": list(x for x in values if x > 0),
        "remove_duplicates": set(values),
        "sort": list(values).sort()
    }

    res = {
        name: func(values)
        for name, func in operations.items()
        if options.get(name, False)
    }

    if not res:
        return values

    return res

    # getting ahead of myself with some tricky stuff
    # will attempt to provide a redundant solution before cleaning up result

print(clean_values(
    10, None, 20, -5, 20, 30,
    remove_none=True,
    remove_negative=True,
    remove_duplicates=True,
    sort=True
))