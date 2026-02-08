- Use field name as default association annoation `as` instead of requiring `as`, then make `as` optional

- implement association method for hasOne, hasMany, belongTo, belongsToMany methods like setX, getX, createX, addX, removeX, hasX, countX, 
- Add support for including all model simple way without using IncludeBuilder(all: true)
- Test querying json field

# Observation
- @Table(underscored: true, createdAt: TimestampOption.custom('createdAt1')) sequelize will create the createdAt column with created_at1 instead of createdAt1 (underscore overriding custom timestamp column names)