#!/usr/bin/env bash
# Deploy the MOE Millwork Estimator into an existing Frappe/ERPNext bench.
# Usage: bash deploy_millwork_estimator.sh mysite.local
set -euo pipefail
SITE=${1:-}
if [ -z "$SITE" ]; then
  echo "Usage: $0 <site-name>"; exit 1
fi

APP_NAME=millwork_estimator
MODULE_TITLE="Millwork Estimator"
APP_TITLE="MOE Millwork Estimator"

# 1) Create app if it doesn't exist
if [ ! -d "apps/$APP_NAME" ]; then
  bench new-app --no-git --app_description "Millwork Operations & Estimating" --app_license MIT --app_publisher "MOE" --app_email "ops@example.com" --python "python3" $APP_NAME <<'EOF'
$APP_TITLE
EOF
fi

# 2) Install app into site
bench --site "$SITE" install-app $APP_NAME || true

APP_PATH="apps/$APP_NAME"
PKG_DIR="$APP_PATH/$APP_NAME"
MODULE_DIR="$PKG_DIR/$APP_NAME"

mkdir -p "$PKG_DIR/config" "$PKG_DIR/doctype" "$PKG_DIR/patches" "$PKG_DIR/report" "$PKG_DIR/utils"

########################################
# hooks.py
########################################
cat > "$PKG_DIR/hooks.py" << 'PY'
from . import __version__ as app_version

app_name = "millwork_estimator"
app_title = "MOE Millwork Estimator"
app_publisher = "MOE"
app_description = "Millwork Operations & Estimating"
app_email = "ops@example.com"
app_license = "MIT"

after_install = "millwork_estimator.patches.setup.seed_catalogs"
after_migrate = "millwork_estimator.patches.setup.seed_catalogs"

# Roles (optional quick-guard)
fixtures = [
    {"doctype": "Role", "filters": {"name": ["in", ["Estimator", "Millwork Admin"]]}},
]
PY

########################################
# patches/setup.py - seed materials & hardware & countertop
########################################
mkdir -p "$PKG_DIR/patches"
cat > "$PKG_DIR/patches/__init__.py" << 'PY'
# empty
PY
cat > "$PKG_DIR/patches/setup.py" << 'PY'
import frappe

MATERIALS = [
    # Plywoods (SF)
    {"material_name": "Baltic Birch Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 2.60},
    {"material_name": "Maple Veneer Plywood (A1)", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 3.40},
    {"material_name": "Red Oak Veneer Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 3.10},
    {"material_name": "White Oak Veneer Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 3.90},
    {"material_name": "Walnut Veneer Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 5.60},
    {"material_name": "Cherry Veneer Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 4.30},
    {"material_name": "Hickory/Pecan Veneer Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 4.10},
    {"material_name": "Mahogany (African) Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 4.90},
    {"material_name": "Ash Veneer Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 3.70},
    {"material_name": "Alder Veneer Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 3.50},
    {"material_name": "Lauan (Luan) Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.25, "cost_per_unit": 1.40},
    {"material_name": "Prefinished UV Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 4.10},
    {"material_name": "Marine-Grade Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 5.40},
    {"material_name": "MDO Plywood (Signboard)", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 3.50},
    {"material_name": "Bending Plywood (Wiggle Board)", "category": "Plywood", "unit": "SF", "thickness_in": 0.25, "cost_per_unit": 3.35},
    {"material_name": "Bamboo Plywood", "category": "Plywood", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 4.75},
    # Engineered Sheet Goods
    {"material_name": "MDF (Standard)", "category": "MDF", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 1.45},
    {"material_name": "Ultralight MDF", "category": "MDF", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 1.80},
    {"material_name": "Moisture-Resistant MDF", "category": "MDF", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 2.20},
    {"material_name": "Fire-Rated MDF", "category": "MDF", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 2.80},
    {"material_name": "Particleboard (Industrial)", "category": "PB", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 1.25},
    {"material_name": "Melamine White TFL", "category": "TFL/Melamine", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 1.65},
    {"material_name": "Melamine Black TFL", "category": "TFL/Melamine", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 1.75},
    {"material_name": "TFL Color/Woodgrain", "category": "TFL/Melamine", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 2.00},
    {"material_name": "Plastic Laminate (HPL)", "category": "HPL/PLAM", "unit": "SF", "thickness_in": 0.05, "cost_per_unit": 1.10},
    {"material_name": "Hardboard (Masonite)", "category": "Backer", "unit": "SF", "thickness_in": 0.125, "cost_per_unit": 0.95},
    # Veneers
    {"material_name": "Wood Veneer (Raw/Paper-backed)", "category": "Veneer", "unit": "SF", "thickness_in": 0.02, "cost_per_unit": 2.50},
    {"material_name": "Reconstituted Veneer", "category": "Veneer", "unit": "SF", "thickness_in": 0.02, "cost_per_unit": 3.10},
    # Solid Woods (BF default)
    {"material_name": "Hard Maple (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 5.20},
    {"material_name": "Soft Maple (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 4.60},
    {"material_name": "Red Oak (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 4.30},
    {"material_name": "White Oak (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 11.50},
    {"material_name": "Cherry (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 6.10},
    {"material_name": "Walnut (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 16.00},
    {"material_name": "Mahogany (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 7.80},
    {"material_name": "Alder (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 4.10},
    {"material_name": "Poplar (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 3.30},
    {"material_name": "Beech (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 5.10},
    {"material_name": "Hickory (Solid)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 6.10},
    {"material_name": "Pine (Solid Softwood)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 3.10},
    {"material_name": "Douglas Fir (Solid Softwood)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 5.80},
    {"material_name": "Cedar (Solid Softwood)", "category": "Solid Wood", "unit": "BF", "thickness_in": 1.0, "cost_per_unit": 7.10},
    # Plastics & Composites
    {"material_name": "HDPE (Plastic Polymer)", "category": "HDPE", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 10.50},
    {"material_name": "Acrylic (High-Gloss Panel)", "category": "Acrylic", "unit": "SF", "thickness_in": 0.75, "cost_per_unit": 5.10},
    {"material_name": "Phenolic Compact Laminate", "category": "Phenolic", "unit": "SF", "thickness_in": 0.5, "cost_per_unit": 10.00},
    {"material_name": "Thermofoil (RTF Finish)", "category": "Thermofoil", "unit": "SF", "thickness_in": 0.03, "cost_per_unit": 4.20},
    # Countertops (SF)
    {"material_name": "Quartz QZ-01", "category": "Top:Quartz", "unit": "SF", "thickness_in": 1.25, "cost_per_unit": 90.00},
    {"material_name": "Quartz QZ-02", "category": "Top:Quartz", "unit": "SF", "thickness_in": 1.25, "cost_per_unit": 98.00},
    {"material_name": "Granite GR-01", "category": "Top:Granite", "unit": "SF", "thickness_in": 1.25, "cost_per_unit": 75.00},
    {"material_name": "Granite GR-02", "category": "Top:Granite", "unit": "SF", "thickness_in": 1.25, "cost_per_unit": 82.00},
    {"material_name": "Plastic Laminate Top PLAM-01", "category": "Top:PLAM", "unit": "SF", "thickness_in": 1.5, "cost_per_unit": 22.00},
    {"material_name": "Plastic Laminate Top PLAM-02", "category": "Top:PLAM", "unit": "SF", "thickness_in": 1.5, "cost_per_unit": 26.00},
    {"material_name": "Solid Surface SS-01", "category": "Top:Solid Surface", "unit": "SF", "thickness_in": 0.5, "cost_per_unit": 65.00},
]

HARDWARE = [
    {"hardware_name": "Standard Hinge", "category": "Hinge", "tier": "Standard", "unit": "EA", "cost_per_unit": 1.25},
    {"hardware_name": "Soft-Close Hinge", "category": "Hinge", "tier": "Soft-Close", "unit": "EA", "cost_per_unit": 2.35},
    {"hardware_name": "Zero-Protrusion Hinge", "category": "Hinge", "tier": "Premium", "unit": "EA", "cost_per_unit": 3.40},
    {"hardware_name": "Drawer Slide (Side-Mount)", "category": "Slide", "tier": "Standard", "unit": "PR", "cost_per_unit": 4.75},
    {"hardware_name": "Drawer Slide (Undermount Soft-Close)", "category": "Slide", "tier": "Soft-Close", "unit": "PR", "cost_per_unit": 9.50},
    {"hardware_name": "Drawer Slide (Heavy Duty)", "category": "Slide", "tier": "Premium", "unit": "PR", "cost_per_unit": 14.00},
    {"hardware_name": "Pull – Economy", "category": "Pull/Knob", "tier": "Economy", "unit": "EA", "cost_per_unit": 1.50},
    {"hardware_name": "Pull – Premium", "category": "Pull/Knob", "tier": "Premium", "unit": "EA", "cost_per_unit": 5.25},
    {"hardware_name": "Knob – Standard", "category": "Pull/Knob", "tier": "Standard", "unit": "EA", "cost_per_unit": 2.10},
    {"hardware_name": "Floating Shelf Bracket (Std)", "category": "Bracket", "tier": "Standard", "unit": "EA", "cost_per_unit": 18.00},
    {"hardware_name": "Floating Shelf Bracket (HD)", "category": "Bracket", "tier": "Heavy Duty", "unit": "EA", "cost_per_unit": 32.00},
    {"hardware_name": "LED Strip Light", "category": "Lighting", "tier": "Standard", "unit": "LF", "cost_per_unit": 14.00},
    {"hardware_name": "LED Puck Light", "category": "Lighting", "tier": "Premium", "unit": "EA", "cost_per_unit": 22.00},
    {"hardware_name": "Pocket Door Kit", "category": "Specialty", "tier": "Specialty", "unit": "EA", "cost_per_unit": 45.00},
]

def upsert(doc:
           dict, doctype: str):
    name = frappe.db.exists(doctype, {list(doc.keys())[0]: list(doc.values())[0]})
    if name:
        d = frappe.get_doc(doctype, name)
        d.update(doc)
        d.save(ignore_permissions=True)
    else:
        d = frappe.get_doc({"doctype": doctype, **doc})
        d.insert(ignore_permissions=True)


def seed_catalogs():
    frappe.clear_cache()
    # roles
    for role in ("Estimator", "Millwork Admin"):
        if not frappe.db.exists("Role", role):
            frappe.get_doc({"doctype": "Role", "role_name": role}).insert(ignore_permissions=True)

    # materials
    for m in MATERIALS:
        upsert(m, "MW Material")
    # hardware
    for h in HARDWARE:
        upsert(h, "MW Hardware")
    frappe.db.commit()
PY

########################################
# utils/resolver.py
########################################
mkdir -p "$PKG_DIR/utils"
cat > "$PKG_DIR/utils/resolver.py" << 'PY'
import frappe

def resolve_material(project_name, room_name, source, direct_material, code, category_hint=None):
    if source == "Direct Material" and direct_material:
        return frappe.get_doc("MW Material", direct_material), "line:direct"

    project = frappe.get_doc("MW Project", project_name)

    def find_code(code_value, room_scope=None):
        filters = {"parent": project.name, "code": code_value}
        if category_hint:
            filters["category"] = category_hint
        if room_scope is not None:
            filters["room"] = room_scope
        rows = frappe.get_all("MW Designation Code", filters=filters, fields=["material", "room", "code", "category"])
        if rows:
            r = rows[0]
            if r.get("material"):
                return frappe.get_doc("MW Material", r["material"]), r
        return None, None

    if source == "Designation Code" and code:
        if room_name:
            m, r = find_code(code, room_scope=room_name)
            if m: return m, "line:code(room)"
        m, r = find_code(code, room_scope="")
        if m: return m, "line:code(project)"

    if source == "Use Room Default" and room_name:
        room_row = next((r for r in project.rooms if r.room_name == room_name), None)
        if room_row:
            mapping = {
                "Finish": room_row.default_finish_code,
                "Interior": room_row.default_interior_code,
                "Countertop": room_row.default_countertop_code,
            }
            for cat, code_value in mapping.items():
                if category_hint == cat and code_value:
                    m, r = find_code(code_value, room_scope=room_name)
                    if m: return m, "room:code(room)"
                    m, r = find_code(code_value, room_scope="")
                    if m: return m, "room:code(project)"
    return None, "none"
PY

########################################
# DocTypes JSON
########################################
mkdoctype(){ mkdir -p "$PKG_DIR/doctype/$1"; }
mkdoctype mw_project
cat > "$PKG_DIR/doctype/mw_project/mw_project.json" << 'JSON'
{
  "doctype": "DocType",
  "name": "MW Project",
  "module": "Millwork Estimator",
  "custom": 0,
  "istable": 0,
  "fields": [
    {"fieldname":"project_name","label":"Project Name","fieldtype":"Data","reqd":1},
    {"fieldname":"customer","label":"Customer","fieldtype":"Link","options":"Customer"},
    {"fieldname":"complexity_factor","label":"Complexity Factor","fieldtype":"Float","default":1.0},
    {"fieldname":"designation_codes","label":"Designation Codes","fieldtype":"Table","options":"MW Designation Code"},
    {"fieldname":"rooms","label":"Rooms","fieldtype":"Table","options":"MW Room"}
  ],
  "permissions": [
    {"role": "Estimator", "read": 1, "write": 1, "create": 1},
    {"role": "Millwork Admin", "read": 1, "write": 1, "create": 1}
  ]
}
JSON

mkdoctype mw_designation_code
cat > "$PKG_DIR/doctype/mw_designation_code/mw_designation_code.json" << 'JSON'
{
  "doctype": "DocType",
  "name": "MW Designation Code",
  "module": "Millwork Estimator",
  "istable": 1,
  "fields": [
    {"fieldname":"code","label":"Code","fieldtype":"Data","reqd":1},
    {"fieldname":"category","label":"Category","fieldtype":"Select","options":"Finish\nInterior\nCountertop\nEdge\nOther"},
    {"fieldname":"material","label":"Material","fieldtype":"Link","options":"MW Material"},
    {"fieldname":"room","label":"Room","fieldtype":"Link","options":"MW Room"},
    {"fieldname":"notes","label":"Notes","fieldtype":"Small Text"}
  ]
}
JSON

mkdoctype mw_room
cat > "$PKG_DIR/doctype/mw_room/mw_room.json" << 'JSON'
{
  "doctype": "DocType",
  "name": "MW Room",
  "module": "Millwork Estimator",
  "istable": 1,
  "fields": [
    {"fieldname":"room_name","label":"Room Name","fieldtype":"Data","reqd":1},
    {"fieldname":"default_finish_code","label":"Default Finish Code","fieldtype":"Data"},
    {"fieldname":"default_interior_code","label":"Default Interior Code","fieldtype":"Data"},
    {"fieldname":"default_countertop_code","label":"Default Countertop Code","fieldtype":"Data"},
    {"fieldname":"notes","label":"Notes","fieldtype":"Small Text"}
  ]
}
JSON

mkdoctype mw_material
cat > "$PKG_DIR/doctype/mw_material/mw_material.json" << 'JSON'
{
  "doctype": "DocType",
  "name": "MW Material",
  "module": "Millwork Estimator",
  "istable": 0,
  "fields": [
    {"fieldname":"material_name","label":"Material Name","fieldtype":"Data","reqd":1},
    {"fieldname":"category","label":"Category","fieldtype":"Select","options":"Plywood\nTFL/Melamine\nMDF\nPB\nHPL/PLAM\nVeneer\nSolid Wood\nHDPE\nPhenolic\nAcrylic\nThermofoil\nBacker\nTop:Quartz\nTop:Granite\nTop:PLAM\nTop:Solid Surface\nMetal\nGlass\nOther","reqd":1},
    {"fieldname":"unit","label":"Unit","fieldtype":"Select","options":"SF\nBF\nLF\nEA","reqd":1},
    {"fieldname":"thickness_in","label":"Thickness (in)","fieldtype":"Float"},
    {"fieldname":"cost_per_unit","label":"Cost per Unit","fieldtype":"Currency"},
    {"fieldname":"vendor_sku","label":"Vendor SKU","fieldtype":"Data"},
    {"fieldname":"notes","label":"Notes","fieldtype":"Small Text"}
  ],
  "permissions": [
    {"role": "Estimator", "read": 1, "write": 1, "create": 1}
  ]
}
JSON

mkdoctype mw_hardware
cat > "$PKG_DIR/doctype/mw_hardware/mw_hardware.json" << 'JSON'
{
  "doctype": "DocType",
  "name": "MW Hardware",
  "module": "Millwork Estimator",
  "istable": 0,
  "fields": [
    {"fieldname":"hardware_name","label":"Hardware Name","fieldtype":"Data","reqd":1},
    {"fieldname":"category","label":"Category","fieldtype":"Select","options":"Hinge\nSlide\nPull/Knob\nBracket\nLighting\nSpecialty","reqd":1},
    {"fieldname":"tier","label":"Tier","fieldtype":"Select","options":"Economy\nStandard\nPremium\nSpecialty"},
    {"fieldname":"unit","label":"Unit","fieldtype":"Select","options":"EA\nPR\nLF"},
    {"fieldname":"cost_per_unit","label":"Cost per Unit","fieldtype":"Currency"},
    {"fieldname":"notes","label":"Notes","fieldtype":"Small Text"}
  ],
  "permissions": [
    {"role": "Estimator", "read": 1, "write": 1, "create": 1}
  ]
}
JSON

mkdoctype mw_estimate
cat > "$PKG_DIR/doctype/mw_estimate/mw_estimate.json" << 'JSON'
{
  "doctype": "DocType",
  "name": "MW Estimate",
  "module": "Millwork Estimator",
  "istable": 0,
  "fields": [
    {"fieldname":"project","label":"Project","fieldtype":"Link","options":"MW Project","reqd":1},
    {"fieldname":"items","label":"Items","fieldtype":"Table","options":"MW Estimate Item"},
    {"fieldname":"total_material_cost","label":"Total Material Cost","fieldtype":"Currency","read_only":1},
    {"fieldname":"total_labor_hours","label":"Total Labor Hours","fieldtype":"Float","read_only":1},
    {"fieldname":"bom_json","label":"BOM JSON (Internal)","fieldtype":"Long Text","read_only":1},
    {"fieldname":"internal_section","label":"Internal","fieldtype":"Section Break"},
    {"fieldname":"hide_from_customer","label":"Hide BOM on Customer Print","fieldtype":"Check","default":1}
  ],
  "permissions": [
    {"role": "Estimator", "read": 1, "write": 1, "create": 1},
    {"role": "Millwork Admin", "read": 1, "write": 1, "create": 1}
  ]
}
JSON

mkdoctype mw_estimate_item
cat > "$PKG_DIR/doctype/mw_estimate_item/mw_estimate_item.json" << 'JSON'
{
  "doctype": "DocType",
  "name": "MW Estimate Item",
  "module": "Millwork Estimator",
  "istable": 1,
  "fields": [
    {"fieldname":"room","label":"Room","fieldtype":"Link","options":"MW Room"},
    {"fieldname":"item_type","label":"Item Type","fieldtype":"Select","options":"Cabinet\nFloating Shelf\nSlat Wall\nDie Wall\nBanquette\nCountertop","reqd":1},

    {"fieldname":"width","label":"Width (in)","fieldtype":"Float"},
    {"fieldname":"height","label":"Height (in)","fieldtype":"Float"},
    {"fieldname":"depth","label":"Depth (in)","fieldtype":"Float"},
    {"fieldname":"length","label":"Length (in)","fieldtype":"Float"},
    {"fieldname":"qty","label":"Quantity","fieldtype":"Int","default":1},

    {"fieldname":"finish_section","label":"Finish","fieldtype":"Section Break"},
    {"fieldname":"finish_source","label":"Finish Source","fieldtype":"Select","options":"Direct Material\nDesignation Code\nUse Room Default\nUse Project Default","default":"Use Room Default"},
    {"fieldname":"finish_material","label":"Finish Material","fieldtype":"Link","options":"MW Material"},
    {"fieldname":"finish_code","label":"Finish Code","fieldtype":"Data"},

    {"fieldname":"interior_section","label":"Interior","fieldtype":"Section Break"},
    {"fieldname":"interior_source","label":"Interior Source","fieldtype":"Select","options":"Direct Material\nDesignation Code\nUse Room Default\nUse Project Default","default":"Use Room Default"},
    {"fieldname":"interior_material","label":"Interior Material","fieldtype":"Link","options":"MW Material"},
    {"fieldname":"interior_code","label":"Interior Code","fieldtype":"Data"},

    {"fieldname":"countertop_section","label":"Countertop","fieldtype":"Section Break"},
    {"fieldname":"countertop_source","label":"Countertop Source","fieldtype":"Select","options":"Direct Material\nDesignation Code\nUse Room Default\nUse Project Default"},
    {"fieldname":"countertop_material","label":"Countertop Material","fieldtype":"Link","options":"MW Material"},
    {"fieldname":"countertop_code","label":"Countertop Code","fieldtype":"Data"},

    {"fieldname":"hardware_section","label":"Hardware","fieldtype":"Section Break"},
    {"fieldname":"hinge","label":"Hinge","fieldtype":"Link","options":"MW Hardware"},
    {"fieldname":"hinge_qty","label":"Hinge Qty","fieldtype":"Int"},
    {"fieldname":"slide","label":"Slide","fieldtype":"Link","options":"MW Hardware"},
    {"fieldname":"slide_qty","label":"Slide Qty (pairs)","fieldtype":"Int"},
    {"fieldname":"pull","label":"Pull/Knob","fieldtype":"Link","options":"MW Hardware"},
    {"fieldname":"pull_qty","label":"Pull/Knob Qty","fieldtype":"Int"},
    {"fieldname":"specialty","label":"Specialty/Bracket/Lighting","fieldtype":"Link","options":"MW Hardware"},
    {"fieldname":"specialty_qty","label":"Specialty Qty (EA/LF)","fieldtype":"Float"},

    {"fieldname":"complexity","label":"Complexity Multiplier","fieldtype":"Float","default":1.0}
  ]
}
JSON

########################################
# Controller for MW Estimate: calc + BOM
########################################
cat > "$PKG_DIR/doctype/mw_estimate/mw_estimate.py" << 'PY'
import json
import frappe
from frappe.model.document import Document
from millwork_estimator.utils.resolver import resolve_material

class MWEstimate(Document):
    def validate(self):
        self.compute_totals_and_bom()

    def compute_totals_and_bom(self):
        bom = {}
        total_material = 0.0
        total_labor = 0.0

        for it in self.items or []:
            m_cost, l_hrs = self._calc_item(it, bom)
            total_material += m_cost
            total_labor += l_hrs

        self.total_material_cost = round(total_material, 2)
        self.total_labor_hours = round(total_labor, 2)
        self.bom_json = json.dumps([
            {"material": k[0], "unit": v["unit"], "qty": round(v["qty"], 4), "room": v.get("room"), "code": v.get("code")}
            for k, v in bom.items()
        ])

    # ---------- helpers ----------
    def _get_material(self, it, role, category_hint):
        src = getattr(it, f"{role}_source", None)
        mat = getattr(it, f"{role}_material", None)
        code = getattr(it, f"{role}_code", None)
        return resolve_material(self.project, it.room, src, mat, code, category_hint)

    def _add_bom(self, bom, mat_doc, unit, qty, room=None, code=None):
        key = (mat_doc.material_name, unit, room or "")
        row = bom.setdefault(key, {"unit": unit, "qty": 0.0, "room": room, "code": code})
        row["qty"] += qty

    # Item calculators (condensed; tailor per module)
    def _calc_item(self, it, bom):
        qty = it.qty or 1
        w = (it.width or 0.0)
        h = (it.height or 0.0)
        d = (it.depth or 0.0)
        L = (it.length or 0.0)
        comp = (it.complexity or 1.0)

        material_cost = 0.0
        labor_hours = 0.0

        def sf(x_in, y_in):
            return (x_in * y_in) / 144.0

        # --- role materials (finish/interior/countertop) ---
        finish_mat, _ = self._get_material(it, "finish", "Finish")
        interior_mat, _ = self._get_material(it, "interior", "Interior")
        ctop_mat, _ = self._get_material(it, "countertop", "Countertop")

        if it.item_type == "Cabinet":
            # Simplified: exterior SF (2 sides + front), interior SF (2 sides + back + bottom)
            ext_sf = sf(h, d) * 2 + sf(w, h)  # rough
            int_sf = sf(h, d) * 2 + sf(w, d) + sf(w, h) * 0.5  # rough
            if finish_mat:
                material_cost += ext_sf * (finish_mat.cost_per_unit or 0)
                self._add_bom(bom, finish_mat, finish_mat.unit or "SF", ext_sf, room=it.room, code=getattr(it, "finish_code", None))
            if interior_mat:
                material_cost += int_sf * (interior_mat.cost_per_unit or 0)
                self._add_bom(bom, interior_mat, interior_mat.unit or "SF", int_sf, room=it.room, code=getattr(it, "interior_code", None))
            # Hardware
            for fld, qtyfld in [("hinge","hinge_qty"),("slide","slide_qty"),("pull","pull_qty"),("specialty","specialty_qty")]:
                hw = getattr(it, fld, None)
                q = getattr(it, qtyfld, 0) or 0
                if hw and q:
                    hw_doc = frappe.get_doc("MW Hardware", hw)
                    material_cost += (hw_doc.cost_per_unit or 0) * q
            # Labor (very rough baseline)
            labor_hours += max(0.25, (w*h*d)/1728.0 * 0.25) * comp * qty

        elif it.item_type == "Floating Shelf":
            # Skin SF: top + bottom + face; braces each 12" OC
            skin_sf = sf(L, d) * 2 + sf(L, (h or 2.0))
            brace_count = int((L or 0)/12.0) + 1
            if finish_mat:
                material_cost += skin_sf * (finish_mat.cost_per_unit or 0)
                self._add_bom(bom, finish_mat, finish_mat.unit or "SF", skin_sf, room=it.room, code=getattr(it, "finish_code", None))
            if interior_mat and brace_count>0:
                brace_sf = sf(d, (h or 2.0)) * brace_count
                material_cost += brace_sf * (interior_mat.cost_per_unit or 0)
                self._add_bom(bom, interior_mat, interior_mat.unit or "SF", brace_sf, room=it.room, code=getattr(it, "interior_code", None))
            # Hardware
            for fld, qtyfld in [("specialty","specialty_qty")]:
                hw = getattr(it, fld, None); q = getattr(it, qtyfld, 0) or 0
                if hw and q:
                    hw_doc = frappe.get_doc("MW Hardware", hw)
                    material_cost += (hw_doc.cost_per_unit or 0) * q
            # Labor baseline
            labor_hours += (0.25 + 0.1*brace_count) * comp * qty

        elif it.item_type == "Slat Wall":
            spacing = 0.5  # could add field
            slat_w = (w or 1.5)
            count = int((L or 0)/(slat_w+spacing))
            lf = (count * (h or 96.0))/12.0
            # board feet from LF*W*T (in)/12
            thickness = (finish_mat.thickness_in if finish_mat else 0.75)
            bf = lf * slat_w * thickness / 12.0
            if finish_mat:
                # if solid wood in BF, otherwise SF
                unit = finish_mat.unit or "SF"
                qtyu = bf if unit=="BF" else (lf * slat_w)/12.0
                material_cost += qtyu * (finish_mat.cost_per_unit or 0)
                self._add_bom(bom, finish_mat, unit, qtyu, room=it.room, code=getattr(it, "finish_code", None))
            labor_hours += max(0.2, 0.1*count) * comp * qty

        elif it.item_type == "Die Wall":
            studs = int((L or 0)/12.0)+1
            face_sf = sf(L or 0, h or 0)
            if finish_mat:
                material_cost += face_sf * (finish_mat.cost_per_unit or 0)
                self._add_bom(bom, finish_mat, finish_mat.unit or "SF", face_sf, room=it.room, code=getattr(it, "finish_code", None))
            if interior_mat and studs>0:
                stud_sf = studs * sf((d or 4.0), (h or 36.0))
                material_cost += stud_sf * (interior_mat.cost_per_unit or 0)
                self._add_bom(bom, interior_mat, interior_mat.unit or "SF", stud_sf, room=it.room, code=getattr(it, "interior_code", None))
            labor_hours += max(0.5, 0.35*((L or 0)/12.0)) * comp * qty

        elif it.item_type == "Banquette":
            seat_depth = d or 18.0
            back_h = max(0.0, (h or 36.0) - 18.0)
            seat_sf = sf(L or 0, seat_depth)
            back_sf = sf(L or 0, back_h)
            if finish_mat:
                material_cost += (seat_sf + back_sf) * (finish_mat.cost_per_unit or 0)
                self._add_bom(bom, finish_mat, finish_mat.unit or "SF", seat_sf+back_sf, room=it.room, code=getattr(it, "finish_code", None))
            ribs = int((L or 0)/16.0)+1
            if interior_mat:
                rib_sf = ribs * sf(seat_depth, 3.0)
                material_cost += rib_sf * (interior_mat.cost_per_unit or 0)
                self._add_bom(bom, interior_mat, interior_mat.unit or "SF", rib_sf, room=it.room, code=getattr(it, "interior_code", None))
            labor_hours += (0.5*((L or 0)/12.0) + 0.1*ribs) * comp * qty

        elif it.item_type == "Countertop":
            top_sf = sf(L or 0, d or 25.0)
            if ctop_mat:
                material_cost += top_sf * (ctop_mat.cost_per_unit or 0)
                self._add_bom(bom, ctop_mat, ctop_mat.unit or "SF", top_sf, room=it.room, code=getattr(it, "countertop_code", None))
            labor_hours += 0.05 * top_sf * comp * qty

        # Hardware common fields added above per type
        return material_cost, labor_hours
PY

########################################
# Simple BOM Report (server script-style)
########################################
cat > "$PKG_DIR/report/bom_rollup.csv.py" << 'PY'
import json
import frappe

def execute(filters=None):
    columns = [
        {"label":"Room","fieldname":"room","fieldtype":"Data","width":150},
        {"label":"Material","fieldname":"material","fieldtype":"Data","width":280},
        {"label":"Unit","fieldname":"unit","fieldtype":"Data","width":60},
        {"label":"Qty","fieldname":"qty","fieldtype":"Float","width":120},
        {"label":"Code","fieldname":"code","fieldtype":"Data","width":80}
    ]
    data = []
    name = filters.get("estimate") if filters else None
    est = frappe.get_doc("MW Estimate", name)
    bom = json.loads(est.bom_json or "[]")
    for row in bom:
        data.append({
            "room": row.get("room"),
            "material": row.get("material"),
            "unit": row.get("unit"),
            "qty": row.get("qty"),
            "code": row.get("code")
        })
    return columns, data
PY

########################################
# finalize, build, migrate
########################################
bench --site "$SITE" migrate
bench --site "$SITE" clear-cache

cat <<MSG

✅ MOE Millwork Estimator deployed to site: $SITE

What you now have:
- DocTypes: MW Project, MW Room, MW Designation Code, MW Material, MW Hardware, MW Estimate, MW Estimate Item
- Seed catalogs for 50+ materials and common hardware tiers
- Designation Code mapping at project/room level (no auto-binding)
- Resolver + calculators with BOM rollup stored on estimate (internal field)
- Sample BOM report (server script): report/bom_rollup.csv.py — add as a Script Report on MW Estimate

Next steps in Desk:
1) Create **MW Project** → add Rooms and Designation Code mappings (PL-1, WD-1, QZ-01, etc.).
2) Create **MW Estimate** for that project → add items → choose sources (Direct, Code, Room Default).
3) Open the **BOM report** (filter by Estimate) to export order-ready materials.

MSG