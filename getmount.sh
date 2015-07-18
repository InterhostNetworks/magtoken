get_storage_info.sh | cut -d, -f9  | cut -d: -f2 | sed -e 's/^"//' -e 's/"$//'
