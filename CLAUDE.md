# CLAUDE.md

## Project Overview

- Create a duckdb database of riders from the Zwift e-cycling game. 
- The database should load data from the [zwiftracing (ZR) api](https://docs.google.com/document/d/1bU9vd23gwGwUsJ6XSoE8wW7O10naEQ_CrhjSnS2sGHY/edit?tab=t.0#heading=h.2wi5u97vykmi)
- Focus on three endpoints; get rider, get club and post riders
- All three endpoints should load data into a ./data/raw.duckdb using dlt
- From the ./data/raw.duckdb, dbt should transform data into ./data/analytics.duckdb 
    - staging schema/layer: set types, set column names, coalesce variant columns
        - dlt will load, e.g. weight as an integer in most cases, but create a variant column of __v_double if it then meets a float; this should coalesce to a single weight value/column per rider - this is the case for many numerical values
            - ``coalesce(weight, weight__v_double)::float as weight``
        - columns names like phenotype__sprinter or handicap__mountain or races__current__rating should become phenotype_sprinter, handicap_mountain, and current_rating
    - intermediate schema/layer: major transformations including creating a human readable datetimestamp of _dlt_load_id and ftp per kg
    - core/production schema; selection of important columns to present in the consumption/BI layer
- Testing can be done with rider ids 4598636, 5574, 5879996 and club id 20650
- Use httpx in python
- The api key is encrypted in sops, in the env as "ZRAPP_API_KEY"
- POST riders will expect a payload that is a list of integers
- Some snippets for the requests:
    ```
    header = {"Authorization": ZRAPP_API_KEY}
    base_url = "https://zwift-ranking.herokuapp.com/public/"
    response = httpx.post(f"{base_url}riders/", headers=header, json=id, timeout=30)
    ```