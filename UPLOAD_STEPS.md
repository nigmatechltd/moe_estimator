# Upload to GitHub (Web UI)

1. Go to your empty repo: https://github.com/jessetreas/moe_estimator
2. Click **Add file → Upload files**.
3. Drag the entire **moe_estimator** folder (this folder) into the upload area.
4. Commit the changes.
5. On Frappe Cloud → Bench → Apps → Add App → Add from GitHub → select `jessetreas/moe_estimator` (branch `main`) → **Validate** → **Add**.
6. Bench → Sites → your site → **Install App** → `moe_estimator`.
7. Site Config → add `"developer_mode": 1` → Save → Rebuild.

## Add your DocTypes
Replace the placeholder `.keep` files in each `doctype/<name>/` with your actual `<name>.json` and `<name>.py` files:
- `doctype/mw_material/{mw_material.json, mw_material.py}`
- `doctype/mw_material_category/{mw_material_category.json, mw_material_category.py}`
- `doctype/millwork_estimate/{millwork_estimate.json, millwork_estimate.py}`
- `doctype/millwork_estimate_item/{millwork_estimate_item.json, millwork_estimate_item.py}`
