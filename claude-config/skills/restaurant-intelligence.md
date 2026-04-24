---
name: restaurant-intelligence
description: Rules for restaurant and F&B intelligence platforms
---
## Data
1. Menu prices in smallest currency unit (paise for INR)
2. Inventory quantities carry their unit (kg, pieces, portions)
3. Order timestamps in UTC, displayed in local timezone
4. Vendor data never modified — only annotated

## Agents
5. No customer-facing messages without confirmation step
6. WhatsApp messages logged before sending, not after
7. Recommendations based on inventory levels, not just history
8. Cost calculations show both unit and extended cost

## Integration
9. PetPooja: verify outlet ID matches before writing
10. Sales data: POS totals match computed totals daily
