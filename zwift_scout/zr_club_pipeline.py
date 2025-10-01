import os
import httpx
import dlt


@dlt.source
def zwift_club_source(club_id: int):
    """
    DLT source that fetches club data from ZwiftRacing GET /club/{id} endpoint.
    This endpoint returns club details including all member riders.

    Args:
        club_id: Zwift club ID to fetch
    """

    @dlt.resource(write_disposition="merge", primary_key="rider_id")
    def riders():
        """Fetch club members (riders) from the ZwiftRacing API."""
        api_key = os.getenv("ZRAPP_API_KEY")
        if not api_key:
            raise ValueError("ZRAPP_API_KEY environment variable not set")

        header = {"Authorization": api_key}
        base_url = "https://zwift-ranking.herokuapp.com/public/"

        # Try clubs endpoint (plural)
        response = httpx.get(
            f"{base_url}clubs/{club_id}",
            headers=header,
            timeout=30
        )
        response.raise_for_status()

        # The club endpoint returns club info with a 'riders' array
        data = response.json()

        # Yield each rider individually
        if "riders" in data and isinstance(data["riders"], list):
            for rider in data["riders"]:
                yield rider
        else:
            # If the response structure is different, yield the whole response
            yield data

    return riders


def run_pipeline(club_id: int = None):
    """
    Run the DLT pipeline to load club rider data into DuckDB.

    Args:
        club_id: Club ID to fetch. Defaults to test club 20650.
    """
    if club_id is None:
        # Default test club ID
        club_id = 20650

    # Create pipeline with DuckDB destination
    pipeline = dlt.pipeline(
        pipeline_name="zwift_club",
        destination=dlt.destinations.duckdb("./data/raw.duckdb"),
        dataset_name="zr_raw"
    )

    # Run the pipeline with merge disposition to update existing riders
    load_info = pipeline.run(zwift_club_source(club_id=club_id))

    print(f"Pipeline completed: {load_info}")


if __name__ == "__main__":
    run_pipeline()
