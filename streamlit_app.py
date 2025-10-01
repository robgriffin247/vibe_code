import streamlit as st
import duckdb
import pandas as pd

# Page config
st.set_page_config(
    page_title="Zwift Scout - Riders",
    page_icon="🚴",
    layout="wide"
)

# Title
st.title("🚴 Zwift Scout - Riders Dashboard")

# Connect to database and load data
@st.cache_data
def load_riders_data():
    conn = duckdb.connect('data/analytics.duckdb')
    query = "SELECT * FROM main_core.riders"
    df = conn.execute(query).fetchdf()
    conn.close()
    return df

# Load data
df = load_riders_data()

# Sidebar filters
st.sidebar.header("Filters")

# Filter by Rider ID
rider_id_filter = st.sidebar.multiselect(
    "Filter by Rider ID",
    options=sorted(df['rider_id'].unique()),
    default=None,
    help="Select one or more rider IDs"
)

# Filter by Name
name_filter = st.sidebar.multiselect(
    "Filter by Name",
    options=sorted(df['name'].unique()),
    default=None,
    help="Select one or more rider names"
)

# Apply filters with OR logic (union of both filters)
filtered_df = df.copy()

if rider_id_filter or name_filter:
    # Create masks for each filter
    id_mask = df['rider_id'].isin(rider_id_filter) if rider_id_filter else pd.Series([False] * len(df))
    name_mask = df['name'].isin(name_filter) if name_filter else pd.Series([False] * len(df))

    # Combine with OR logic
    combined_mask = id_mask | name_mask
    filtered_df = df[combined_mask]

# Display metrics
col1, col2, col3, col4 = st.columns(4)
with col1:
    st.metric("Total Riders", len(filtered_df))
with col2:
    st.metric("Avg FTP", f"{filtered_df['ftp'].mean():.0f}W" if len(filtered_df) > 0 else "N/A")
with col3:
    st.metric("Avg FTP/kg", f"{filtered_df['ftp_per_kg'].mean():.2f}" if len(filtered_df) > 0 else "N/A")
with col4:
    st.metric("Total Races", filtered_df['finishes'].sum() if len(filtered_df) > 0 else 0)

st.divider()

# Display table
st.subheader("Riders Data")
st.dataframe(
    filtered_df,
    use_container_width=True,
    height=600
)

# Show record count
st.caption(f"Showing {len(filtered_df)} of {len(df)} riders")
