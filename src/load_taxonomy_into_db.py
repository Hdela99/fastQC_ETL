import sqlite3
import json
import sys
import os
from pathlib import Path

def load_taxonomy_info(srr_id, fastp_json_path, db_path):
    