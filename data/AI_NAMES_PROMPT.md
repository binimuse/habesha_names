You are helping build the name list for "Habesha Names", an Ethiopian and Eritrean baby-names app. Please produce new names in the exact format below. The output is pasted into an importer that rejects any row that breaks these rules, so follow them precisely.

## Output format

- Output **CSV only**, inside one ```csv code block. Put no other text inside the block.
- The **first line is this header, exactly**:

```
id,name_latin,name_geez,spellings,gender,languages,faiths,meaning_en,meaning_am,themes,pronunciation,audio_url,syllables,easy_abroad,origin_en,origin_am,nicknames,similar,famous,verified,popularity,modern
```

- Every row has exactly **22 columns**. Leave a column empty if you don't know it, but keep the commas.
- If a value contains a comma, put it in double quotes: `"Gift, blessing"`. Write a literal `"` as `""`.
- **Lists** (spellings, languages, faiths, themes, nicknames, similar, famous) separate items with `|` and no spaces: `amharic|tigrinya`.
- **Batch size:** 100 names per reply. After each batch, I'll say "next" for another 100.

## Columns

| Column | Rule |
|---|---|
| `id` | Lowercase Latin letters, digits and `-` only, e.g. `hiwot`, `bete-mariam`. Must be unique: never reuse an id from the "Already exists" list or from an earlier batch. |
| `name_latin` | **Required.** The most common English spelling, e.g. `Hiwot`. |
| `name_geez` | **Required.** Ge'ez script (ፊደል) only, e.g. `ሕይወት`. Don't use Latin letters here. |
| `spellings` | Other Latin spellings, e.g. `Hiwet\|Hewan`. Don't repeat `name_latin`. |
| `gender` | **Required.** Exactly `girl`, `boy` or `unisex`. |
| `languages` | One or more of `amharic`, `tigrinya`, `oromo`, and nothing else. Use the languages the name is actually used in. |
| `faiths` | One or more of `orthodox`, `protestant`, `catholic`, `muslim`, `neutral`, and nothing else. Use `neutral` for names with no religious tie. Biblical names usually get `orthodox\|protestant\|catholic`. Arabic and Islamic names get `muslim`. |
| `meaning_en` | Short English meaning, 2–10 words, e.g. `Life`. |
| `meaning_am` | The same meaning in Amharic (Ge'ez script), e.g. `ሕይወት`. |
| `themes` | Zero or more of `nature`, `faith`, `peace`, `love`, `light`, `hope`, `strength`, `joy`, `life`, `virtue`, `history`, and nothing else. |
| `pronunciation` | Simple guide with the stressed syllable in capitals, e.g. `hee-WOT`. |
| `audio_url` | **Always leave empty.** |
| `syllables` | Whole number, 1–12. |
| `easy_abroad` | `true` if English speakers can say and spell it easily, otherwise `false`. |
| `origin_en` | e.g. `Amharic`, `Ge'ez`, `Hebrew (biblical)`, `Arabic`, `Afaan Oromo`, `Tigrinya`. |
| `origin_am` | The same in Amharic, e.g. `አማርኛ`, `ግዕዝ`, `ዕብራይስጥ`, `ዐረብኛ`, `ኦሮምኛ`, `ትግርኛ`. |
| `nicknames` | Common short forms, e.g. `Hiwi`. |
| `similar` | Ids of similar names, from this batch or the "Already exists" list only. |
| `famous` | Well-known people with this name, if you're sure. Otherwise leave it empty. |
| `verified` | **Always `false`.** A native speaker reviews names later. |
| `popularity` | Whole number 0–100: your estimate of how common the name is today (90+ very common, under 20 rare). |
| `modern` | `true` for names that became popular mainly after about 2000, e.g. Bethel, Arsema, Elnathan, Ruhama. Otherwise `false`. |

## Quality rules

- **Only include names you're confident about.** If you're unsure of a meaning or a Ge'ez spelling, leave that name out rather than guess.
- **No duplicates**, including the same name under a different Latin spelling. Hiwot and Hiwet are one name: put the variant in `spellings`.
- If the same name is used for both girls and boys, write one row with `unisex`, not two rows.
- Don't copy text from websites. Use your own knowledge.

## Example rows

```csv
id,name_latin,name_geez,spellings,gender,languages,faiths,meaning_en,meaning_am,themes,pronunciation,audio_url,syllables,easy_abroad,origin_en,origin_am,nicknames,similar,famous,verified,popularity,modern
hiwot,Hiwot,ሕይወት,Hiwet,girl,amharic|tigrinya,neutral,Life,ሕይወት,life,hee-WOT,,2,true,Ge'ez,ግዕዝ,Hiwi,selam,,false,80,false
amanuel,Amanuel,አማኑኤል,Emmanuel|Amanueal,boy,amharic|tigrinya,orthodox|protestant|catholic,"God is with us",እግዚአብሔር ከእኛ ጋር ነው,faith,ah-mah-NU-el,,4,true,Hebrew (biblical),ዕብራይስጥ,Amani,,,false,85,false
```

## Already exists: don't use these ids or these names

abebe, ahmed, amanuel, amina, betelhem, biftu, birhan, chaltu, dawit, eyob, fikir, gemechu, haile, hana, hayat, hiwot, kedir, kidist, lidya, mehari, mekdes, meron, nahom, netsanet, nuria, seid, selam, senait, tamrat, tesfaye, tirunesh, tsehay, tsion, yared, yonas

## Order of batches

1. Amharic and Ge'ez names (girls, then boys)
2. Biblical and Orthodox names
3. Muslim and Arabic names used in Ethiopia and Eritrea
4. Afaan Oromo names
5. Tigrinya names
6. Modern and trending names

Start with batch 1: 100 names.
