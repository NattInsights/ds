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
print(clean_values(
    10, None, 20, -5, 20, 30,
    remove_none=True,
    remove_negative=True,
    remove_duplicates=True,
    sort=True
))
