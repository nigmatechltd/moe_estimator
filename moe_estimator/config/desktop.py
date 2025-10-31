from frappe import _

def get_data():
    return [{
        "module_name": "Millwork Estimator",
        "category": "Modules",
        "label": _("Millwork Estimator"),
        "color": "grey",
        "icon": "octicon octicon-graph",
        "type": "module",
        "description": _("Millwork estimating and materials.")
    }]
