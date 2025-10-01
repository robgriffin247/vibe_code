import os
import httpx
import dlt


@dlt.source
def zwift_riders_source(rider_ids: list[int]):
    """
    DLT source that fetches rider data from ZwiftRacing POST /riders endpoint.

    Args:
        rider_ids: List of Zwift rider IDs to fetch
    """

    @dlt.resource(write_disposition="replace")
    def riders():
        """Fetch riders data from the ZwiftRacing API."""
        api_key = os.getenv("ZRAPP_API_KEY")
        if not api_key:
            raise ValueError("ZRAPP_API_KEY environment variable not set")

        header = {"Authorization": api_key}
        base_url = "https://zwift-ranking.herokuapp.com/public/"

        response = httpx.post(
            f"{base_url}riders/",
            headers=header,
            json=rider_ids,
            timeout=30
        )
        response.raise_for_status()

        # Yield the response data
        data = response.json()
        yield data

    return riders


def run_pipeline(rider_ids: list[int] = None):
    """
    Run the DLT pipeline to load rider data into DuckDB.

    Args:
        rider_ids: List of rider IDs to fetch. Defaults to test IDs.
    """
    if rider_ids is None:
        # Default test rider IDs
        rider_ids = [4598636, 5574, 5879996]

    # Create pipeline with DuckDB destination
    pipeline = dlt.pipeline(
        pipeline_name="zwift_riders",
        destination=dlt.destinations.duckdb("./data/raw.duckdb"),
        dataset_name="zr_raw"
    )

    # Run the pipeline
    load_info = pipeline.run(zwift_riders_source(rider_ids=rider_ids))

    print(f"Pipeline completed: {load_info}")


if __name__ == "__main__":
    run_pipeline()
