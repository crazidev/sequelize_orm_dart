# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-02-17

### Changes

---

Packages with other changes:

 - [`sequelize_orm` - `v0.1.4`](#sequelize_orm---v014)
 - [`sequelize_orm_generator` - `v0.1.4`](#sequelize_orm_generator---v014)

---

#### `sequelize_orm` - `v0.1.4`

 - **FEAT**: Enhanced enum query accessors with prefix shortcuts (`isActive`, `notActive`) and grouped `eq`/`not` operators.
 - **FEAT**: Added `@EnumPrefix` annotation supporting both positive and opposite prefixes.
 - **FIX**: Improved null check API by converting `isNull` and `isNotNull` to standard methods.

#### `sequelize_orm_generator` - `v0.1.4`

 - **FEAT**: Implemented multi-layered enum query API (shortcuts + grouped accessors).
 - **FEAT**: Support for custom enum prefixes via `@EnumPrefix` annotation.
 - **FIX**: Sanitized and simplified generated enum classes and member naming conventions.

---

## 2026-02-12

### Changes

---

Packages with breaking changes:

 - [`sequelize_orm_example` - `v2.0.0`](#sequelize_orm_example---v200)

Packages with other changes:

 - [`sequelize_orm` - `v0.1.0+1`](#sequelize_orm---v0101)
 - [`sequelize_orm_generator` - `v0.1.0+1`](#sequelize_orm_generator---v0101)

---

#### `sequelize_orm_example` - `v2.0.0`

 - **REFACTOR**: rename packages for pub.dev discoverability and add melos workspace management. ([c3c3cb69](https://github.com/crazidev/sequelize_orm_dart/commit/c3c3cb695b555bfe8d3cbfa98c10bbc4e00c8259))
 - **REFACTOR**: consolidate connection options and modernize model naming convention. ([6cb0d729](https://github.com/crazidev/sequelize_orm_dart/commit/6cb0d729f15eda65132bf07c0906f1cb1c86780e))
 - **REFACTOR**: change generated class naming from prefix to suffix-based convention. ([83138a1b](https://github.com/crazidev/sequelize_orm_dart/commit/83138a1b15b5fc6fdc7739a781223e5c6d39a2c1))
 - **REFACTOR**: Extract _updateFields helper to reduce generated code duplication. ([3ddc48aa](https://github.com/crazidev/sequelize_orm_dart/commit/3ddc48aa2ea4d16b196254af64820563d1f0ad46))
 - **REFACTOR**: unify bridge server into single bundle. ([5b8d2ec9](https://github.com/crazidev/sequelize_orm_dart/commit/5b8d2ec9474e392bdff0ab290cb5b77871331d31))
 - **REFACTOR**: unify bridge pattern for Dart VM and dart2js. ([f7de41c5](https://github.com/crazidev/sequelize_orm_dart/commit/f7de41c57c2b244dc191f165877681271635f5a8))
 - **REFACTOR**(bridge): convert Node.js bridge from JavaScript to TypeScript. ([7fb144da](https://github.com/crazidev/sequelize_orm_dart/commit/7fb144da082042f1afa6f0bb92ef892fa2d69aba))
 - **REFACTOR**: reorganize tests to workspace root. ([eca5145a](https://github.com/crazidev/sequelize_orm_dart/commit/eca5145ac23fe8a6de09238c4de89491b4654494))
 - **FIX**: Convert Dart query operators to Sequelize Op symbols in JS build. ([0a36e140](https://github.com/crazidev/sequelize_orm_dart/commit/0a36e140b02873f40abb9537f66546bfcad572ac))
 - **FIX**: Update logging behavior and query execution in example/lib/main.dart. ([d3144959](https://github.com/crazidev/sequelize_orm_dart/commit/d314495926e8654557967e36eedf883748cb082a))
 - **FIX**: support both user/username and pass/password in sequelize.yaml and ensure 'user' is sent to bridge. ([d38c9e3e](https://github.com/crazidev/sequelize_orm_dart/commit/d38c9e3ef3372104b87eccd4db2f96ca431cf53b))
 - **FIX**: resolve SequelizeConnectionError by correctly mapping user to username in core_options.dart. ([6899a2a4](https://github.com/crazidev/sequelize_orm_dart/commit/6899a2a485882681e194b6bc938c9d0cc14e0192))
 - **FIX**: harden model generation and runtime serialization. ([c734bb10](https://github.com/crazidev/sequelize_orm_dart/commit/c734bb10d722b41e72453df46c20a98c8ac16e99))
 - **FIX**: Preserve foreign keys when saving instances. ([1a9b1758](https://github.com/crazidev/sequelize_orm_dart/commit/1a9b1758db23698a5788bb7acc92a1d767ba35d9))
 - **FIX**: Handle different increment/decrement result formats. ([dc94fc13](https://github.com/crazidev/sequelize_orm_dart/commit/dc94fc1317562b3f17eaf7c8ce813643dacbdbc7))
 - **FIX**: Add explicit types for pkWhere and remove const from $ModelQuery. ([94dda329](https://github.com/crazidev/sequelize_orm_dart/commit/94dda3294d0dc3bfb9e581ddf69dd917ab1acba3))
 - **FIX**: Update post increment logic to capture updated post instance. ([1e70b3d6](https://github.com/crazidev/sequelize_orm_dart/commit/1e70b3d60a8a49cffdab6fa065651bfcbb89a7be))
 - **FIX**(sequelize): remove hoistIncludeOptions from config passed to Sequelize constructor. ([3643a4a2](https://github.com/crazidev/sequelize_orm_dart/commit/3643a4a2a10b8863c910ee6493bdf8582f63c25e))
 - **FEAT**: refine error formatting and implement SequelizeException hierarchy. ([6286da98](https://github.com/crazidev/sequelize_orm_dart/commit/6286da98008332003c18505474f4072c06dd5b23))
 - **FEAT**: Add fluent JSON query API with JsonColumn and JsonPath. ([0554ac34](https://github.com/crazidev/sequelize_orm_dart/commit/0554ac34fa53788a137c440460504be518ffa6ee))
 - **FEAT**: Enhance query operator support in Sequelize Dart. ([5177b340](https://github.com/crazidev/sequelize_orm_dart/commit/5177b3403e958183987c86af88ccf0e113a890a2))
 - **FEAT**: Add destroy, truncate, restore operations and paranoid mode support. ([ee41974d](https://github.com/crazidev/sequelize_orm_dart/commit/ee41974d97291ccb18aad5a085ee30148f6d3d20))
 - **FEAT**: Add Sequelize instance metadata (previous, changed, isNewRecord). ([577c7832](https://github.com/crazidev/sequelize_orm_dart/commit/577c78326d33bc7f7f9258c4ef9e3f99156e2b97))
 - **FEAT**: enhance sequelize_dart_generator with .env support, advanced connection profiles, and verbose seeding. ([29d8ec8a](https://github.com/crazidev/sequelize_orm_dart/commit/29d8ec8afdade2ac2c6cd65fb83401105108c305))
 - **FEAT**: add CLI seeding with sequelize.yaml config and auto registry generation. ([a07ee61a](https://github.com/crazidev/sequelize_orm_dart/commit/a07ee61a8433fb57ee6049e3b6da9803ea72167c))
 - **FEAT**: add seeding base API and move example models to db/. ([9f776196](https://github.com/crazidev/sequelize_orm_dart/commit/9f776196df52382c487cc2df271fd3e1a3d6e43b))
 - **FEAT**: Restore reload() instance method with in-place field updates. ([0f0a64e1](https://github.com/crazidev/sequelize_orm_dart/commit/0f0a64e142516a01427c60848bbc870379d77c4f))
 - **FEAT**: Allow reload() to work without _originalQuery using primary key. ([9080bbd8](https://github.com/crazidev/sequelize_orm_dart/commit/9080bbd851ab17164306f38fcb2f15b252d8c8fc))
 - **FEAT**: Add instance methods (increment, decrement, reload) with in-place field updates. ([3925394d](https://github.com/crazidev/sequelize_orm_dart/commit/3925394d9fa16a8d9f2487471408776ad6af938a))
 - **FEAT**: expand multi-dialect test support (mysql/mariadb). ([8c13dc4b](https://github.com/crazidev/sequelize_orm_dart/commit/8c13dc4b1228bd2556ac407f36285b044d06001d))
 - **FEAT**: Introduce VS Code extension for model generation and enhance generator with improved DataType field parsing. ([47d82538](https://github.com/crazidev/sequelize_orm_dart/commit/47d82538ac9fd902a437eb43465fefd38c2b7b1f))
 - **FEAT**: Implement type-safe query builders for findAll and findOne methods. ([9f8f151c](https://github.com/crazidev/sequelize_orm_dart/commit/9f8f151c4bce15336eb7a32c4eddce8988c08b5e))
 - **FEAT**: Add bridge logging, benchmarking, and fix queries. ([0b7f659b](https://github.com/crazidev/sequelize_orm_dart/commit/0b7f659ba072692780980ed2ae0052a71480ced9))
 - **FEAT**: implement utility methods (count, max, min, sum). ([de572cbf](https://github.com/crazidev/sequelize_orm_dart/commit/de572cbfce72442afc3a9a6a662d0b40bb662a84))
 - **FEAT**: add debug flag to createInstance to enable internal setup logs. ([ca3f591d](https://github.com/crazidev/sequelize_orm_dart/commit/ca3f591de621816c9cf266f667dfaa6d0097892d))
 - **FEAT**(sequelize): implement joined include ordering hoisting and complex SQL expressions support. ([a6c0019a](https://github.com/crazidev/sequelize_orm_dart/commit/a6c0019af3ae4b498dcb02d3ceacc7c79f80d12d))
 - **FEAT**: Initial release of Sequelize Dart - A comprehensive Dart ORM for Sequelize.js. ([f06b6e1e](https://github.com/crazidev/sequelize_orm_dart/commit/f06b6e1ef5e096c63cbb6ab9f0f154155aa97c21))
 - **FEAT**: enhance IncludeBuilder with duplicating, on, or, and subQuery properties. ([e08cada8](https://github.com/crazidev/sequelize_orm_dart/commit/e08cada8a7c485b72dca0c1df13b3b695c5134be))
 - **FEAT**: Add models registry generator. ([10518613](https://github.com/crazidev/sequelize_orm_dart/commit/1051861329fbfffdfe481bd9fa58e8dc0f54705e))
 - **FEAT**: improve query callback naming and generator config. ([c2f434f7](https://github.com/crazidev/sequelize_orm_dart/commit/c2f434f74de75b155f9114375b2542ea3b27c362))
 - **FEAT**: Add `where` clause to included posts and set SQL formatter to red theme. ([c741bfb2](https://github.com/crazidev/sequelize_orm_dart/commit/c741bfb22ca23eb07faaf947dae1f3bb5d789490))
 - **FEAT**: Introduce AnsiColor enum and refactor SQL formatter for enhanced tokenization and highlighting, updating example usage. ([e5d498a8](https://github.com/crazidev/sequelize_orm_dart/commit/e5d498a80820880851db47eedb85488eebe31be3))
 - **FEAT**: Introduce `getQueryBuilder` for models to streamline nested include processing and enhance JS query option conversion. ([9dcb7845](https://github.com/crazidev/sequelize_orm_dart/commit/9dcb7845058185d065accd2f16705471804b617e))
 - **FEAT**: Default `separate` in `IncludeBuilder` and update example queries for associations. ([ee8a1867](https://github.com/crazidev/sequelize_orm_dart/commit/ee8a1867f003960c09169277c9c1230ba9b4347c))
 - **FEAT**: Implement type-safe association includes with generated query builders and new include builder classes. ([5f58bbe2](https://github.com/crazidev/sequelize_orm_dart/commit/5f58bbe2b8c38b525fd933806a5f0b4ddd4154a5))
 - **FEAT**: Introduce a comprehensive validation framework. ([a5cec3d5](https://github.com/crazidev/sequelize_orm_dart/commit/a5cec3d52c0c4caa28570e18ac103ff67d603002))
 - **FEAT**: Add file watcher task and update launch configurations. ([34497755](https://github.com/crazidev/sequelize_orm_dart/commit/34497755e8e90bfafe3dc15dc14555cdf9bd81cc))
 - **FEAT**: Enhance model association handling and initialization. ([55ae10eb](https://github.com/crazidev/sequelize_orm_dart/commit/55ae10eb4f99616644affdebd95de97dffc139af))
 - **FEAT**: Add SQL logging callback support via JSON-RPC notifications. ([e1f81314](https://github.com/crazidev/sequelize_orm_dart/commit/e1f81314f5ca6521913764bdc5e4648e62f65881))
 - **FEAT**(example): Add query examples and measureQuery utility. ([681081de](https://github.com/crazidev/sequelize_orm_dart/commit/681081de316eb52881c181cf3a2e39d583488e12))
 - **FEAT**: Add example `sequelize.yaml` configuration and a new test helper, and update documentation tasks for related features. ([c5a3655f](https://github.com/crazidev/sequelize_orm_dart/commit/c5a3655f0cf7a0d0ceb5f39e6eebb85a7d597d9e))
 - **FEAT**: Add `copyWith` method to `IncludeBuilder` and demonstrate its use for specifying include attributes. ([a75063c5](https://github.com/crazidev/sequelize_orm_dart/commit/a75063c5035775d72bc7ac3a17b61e6621ca52c6))
 - **DOCS**: Add comprehensive TODO comments for changed() and previous() implementation. ([dfdc5b3a](https://github.com/crazidev/sequelize_orm_dart/commit/dfdc5b3a19667d75201bf37b6ef5526770f37601))
 - **DOCS**: Update get-started guide and improve seed user post metadata. ([7a065d9c](https://github.com/crazidev/sequelize_orm_dart/commit/7a065d9c430a813b288414e334a624f95a7f56dd))
 - **BREAKING** **FEAT**: implement shared increment and decrement functionality. ([9a2365e7](https://github.com/crazidev/sequelize_orm_dart/commit/9a2365e7bc1aa8455b95302b2dacbd085f559ee8))

#### `sequelize_orm` - `v0.1.0+1`

 - **REFACTOR**: rename packages for pub.dev discoverability and add melos workspace management. ([c3c3cb69](https://github.com/crazidev/sequelize_orm_dart/commit/c3c3cb695b555bfe8d3cbfa98c10bbc4e00c8259))
 - **FIX**: harden model generation and runtime serialization. ([c734bb10](https://github.com/crazidev/sequelize_orm_dart/commit/c734bb10d722b41e72453df46c20a98c8ac16e99))
 - **DOCS**: prepare packages for pub.dev publishing and split CLI commands. ([98083c73](https://github.com/crazidev/sequelize_orm_dart/commit/98083c73f80f3156d3ec98de1c093b658180a61a))

#### `sequelize_orm_generator` - `v0.1.0+1`

 - **REFACTOR**: rename packages for pub.dev discoverability and add melos workspace management. ([c3c3cb69](https://github.com/crazidev/sequelize_orm_dart/commit/c3c3cb695b555bfe8d3cbfa98c10bbc4e00c8259))
 - **FIX**: harden model generation and runtime serialization. ([c734bb10](https://github.com/crazidev/sequelize_orm_dart/commit/c734bb10d722b41e72453df46c20a98c8ac16e99))
 - **DOCS**: prepare packages for pub.dev publishing and split CLI commands. ([98083c73](https://github.com/crazidev/sequelize_orm_dart/commit/98083c73f80f3156d3ec98de1c093b658180a61a))

