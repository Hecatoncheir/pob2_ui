# Снимки работающего приложения

Снимки сделаны 11 ноября 2026 года на Windows. Это исходные PNG Flutter из отдельных тестовых профилей. Игровые данные и показатели получены через PoB v0.23.1 и MCP v0.18.1.

`progression-hover` и `progression-edit` сняты в PoB II v0.1.23, ревизия `e0ef359`. В тестовой сборке выбран этап 25-го уровня. На первом снимке наведение на узел включает подсветку на дереве, на втором открыт диалог изменения уровня.

Снимки раздела v0.1.22 и остальных возможностей сделаны на ревизии `f39207c`.

- `tree-dark`, `node-power`, `components`: сценарий `integration_test/workspace_test.dart`.
- `skills`: сценарий `integration_test/editors_test.dart`.
- `equipment`, `comparison`, `trade`: сценарий `integration_test/equipment_test.dart`.
- `setup-wizard`, `library`, `tree-light`, `settings`: отдельный локальный прогон той же ревизии. Мастер снят с пустым профилем. Для дерева, библиотеки и настроек использованы тестовые XML из сквозной проверки.
- `setup-lua`, `setup-builds`: мастер после подключения настоящего Lua и после поиска через мост отдельного экземпляра Path of Building. Путь ведёт к демонстрационной папке.

Снимки сценариев выпуска доступны в артефакте `ui-windows-x64`. [Проверки выпуска v0.1.22](https://github.com/Hecatoncheir/pob2_ui/actions/runs/43002582595)

Изображения игровых объектов принадлежат Grinding Gear Games.
