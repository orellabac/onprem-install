db.users.update({ searchableEmail: '{{EMAIL_ADDR}}' }, { $set: { username: '{{NEW_USER_NAME}}' } });
db.users.find({ searchableEmail: '{{EMAIL_ADDR}}' }, { _id: 1, username: 1 }).forEach(printjson);
