db.users.find({searchableEmail:'{{EMAIL_ADDRESS}}'}, {_id:1}).forEach(printjson);
