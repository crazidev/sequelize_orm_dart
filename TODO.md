- Use field name as default association annoation `as` instead of requiring `as`, then make `as` optional

- implement association method for hasOne, hasMany, belongTo, belongsToMany methods like setX, getX, createX, addX, removeX, hasX, countX, 

- Do not depend build_runner or cli generator on db.registry.dart to generate registry file, do it automatically, if build_runner isn't compatible to generate file when another dosen't exist then you can only implement for cli.

- Document `sequelize.yaml` config format (models_path, seeders_path, databases profiles, dialect/url)

- Document CLI `--seed` usage (url, database profile, dialect override, alter/force flags)

- Document programmatic seeding: `sequelize.seed(seeders: ..., syncTableMode: SyncTableMode.*)` and logging hooks

- Document seeder authoring conventions: `*.seeder.dart`, `Seeders.all()`, `order`, and `create => Db.<model>.create`