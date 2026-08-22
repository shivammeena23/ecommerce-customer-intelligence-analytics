# Streamlit Dashboard — Deployment Guide

This is a deployable, browser-based version of the Power BI dashboard, built with
Streamlit + Plotly on top of the same processed analytical outputs
(`data/processed/*.csv`) from the main pipeline.

## Run locally

```bash
cd streamlit_app
pip install -r requirements.txt
streamlit run app.py
```

This opens the app at `http://localhost:8501`.

## Deploy for free (Streamlit Community Cloud)

1. Push this repository to GitHub (make sure `streamlit_app/` is included).
2. Go to [share.streamlit.io](https://share.streamlit.io) and sign in with GitHub.
3. Click **New app**, select this repository, and set:
   - **Branch:** `main`
   - **Main file path:** `streamlit_app/app.py`
4. Click **Deploy**. You'll get a public URL like:
   `https://<your-app-name>.streamlit.app`

That's it — no server, no Docker, free tier is sufficient for this app size.

## Add the live link to your resume / README

Once deployed, put the link:
- In the main `README.md` under "Power BI Dashboard" (or a new "Live Demo" badge at the top).
- On your resume next to the project title.
- On LinkedIn under this project's featured section.

## What's included vs. the full pipeline

This app uses only the lightweight, pre-aggregated CSVs in `data/` (a copy of the
relevant files from `data/processed/`) — it does **not** re-run the SQL or the
K-Means clustering live. That's intentional: it keeps the app fast and free to
host, while the full reproducible pipeline (SQL scripts + notebooks) remains in
the main repo for anyone who wants to verify the methodology end-to-end.
