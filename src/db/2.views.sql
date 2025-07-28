/* 
 SPDX-License-Identifier: CC-BY-NC-4.0
 Copyright (c) Leandro Lopes Pereira. Some rights reserved.
 See LICENSE file for full details.
*/

-- View for the top card of each tableau pile
-- Shows the bottom-most card where new cards can be attached
-- following suit color and descending rank rules

DROP VIEW IF EXISTS tableau_tops;
CREATE VIEW tableau_tops AS
SELECT  d.TableauCol, d.TableauRow, d.Suit, d.Rank, d.FaceUp, d.Color, d.Label
FROM    Deck d
JOIN    (SELECT TableauCol, MAX(TableauRow) AS TableauRow
         FROM   Deck
         WHERE  InTableau
         GROUP BY TableauCol) AS max_row
USING   (TableauCol, TableauRow);

------------------------------------------------------------

-- Foundation view - The game's objective is to move all cards here
-- Suits are fixed in a specific order to improve gameplay

DROP VIEW IF EXISTS foundation;
CREATE VIEW foundation AS  
WITH Suits(Suit) AS (VALUES ('♠'), ('♣'), ('♥'), ('♦'))
SELECT n.Suit,
       COALESCE(d.Label, n.Suit) AS Label,
       COALESCE(d.Rank, 0) AS Rank,
       ROW_NUMBER() OVER (ORDER BY n.Suit) AS col
FROM Suits n
LEFT JOIN (
    SELECT Suit, MAX(Rank) AS MaxRank
    FROM Deck
    WHERE InFoundation
    GROUP BY Suit
) AS sub ON sub.Suit = n.Suit
LEFT JOIN Deck d 
ON d.Suit = sub.Suit 
AND d.Rank = sub.MaxRank;

------------------------------------------------------------
-- Main game view

DROP VIEW IF EXISTS game_view;
CREATE VIEW game_view('1(♠)', '2(♣)', '3(♥)', '4(♦)', ' ', 'Waste', 'Stock', '  ') AS

-- Check if game is won
WITH won AS (SELECT ( 52 = (SELECT COUNT(*) FROM Deck WHERE InFoundation)) AS won)
SELECT                             -- Foundation cards
    MAX(IIF(col = 1, Label, '')),  -- ♠
    MAX(IIF(col = 2, Label, '')),  -- ♣
    MAX(IIF(col = 3, Label, '')),  -- ♥
    MAX(IIF(col = 4, Label, '')),  -- ♦
    ' ',                           -- Blank space, separating from waste pile
    COALESCE((SELECT Label FROM Deck WHERE IsWasteTop), '') AS WasteCard, -- Top card of waste pile
    CASE 
        WHEN 0 = (SELECT COUNT(1) FROM Deck WHERE InStock) THEN 'ᴥ'
        WHEN (SELECT IIF(IsWasteTop, SortOrder, 0) = MAX(SortOrder) FROM Deck WHERE InStock) THEN ''
        ELSE
            printf('%.*c',         -- Stock pile progress indicator
                1 +
                FLOOR(
                    (1 - (
                        (SELECT pos FROM (
                            SELECT ROW_NUMBER() OVER(ORDER BY SortOrder) AS pos, IsWasteTop
                            FROM Deck
                            WHERE InStock
                        ) a WHERE IsWasteTop)
                        / CAST((SELECT COUNT(*) FROM Deck WHERE InStock) AS REAL)
                    )) * 5
                ),
                '▒'
            )
    END AS StockBar,
    COALESCE(
        '(' || (
            SELECT pos 
            FROM (
                SELECT ROW_NUMBER() OVER(ORDER BY SortOrder) || '/' || COUNT(*) OVER() AS pos, IsWasteTop
                FROM Deck
                WHERE InStock
            ) a
            WHERE IsWasteTop
        ) || ')',
        ''
    ) AS StockPos -- Position in stock pile
FROM foundation

UNION ALL
SELECT 'Tableau', '(' || (SELECT COUNT(1) FROM Deck WHERE InTableau) || ')', '', '', '', '', '', '' -- Separator between foundation/stock pile and tableau
UNION ALL

SELECT * from (values('Row', 'Col1', 'Col2', 'Col3', 'Col4', 'Col5', 'Col6', 'Col7') /* Tableau column headers*/
                    ,('---', '----', '----', '----', '----', '----', '----', '----') /* Visual separator*/ )

UNION ALL

-- Display tableau cards. Hidden cards shown as ▒, revealed cards show their value
-- Only shown if player hasn't won yet
SELECT TableauRow,
    MAX(CASE WHEN TableauCol = 1 THEN IIF(FaceUp, Label, '▒') ELSE '' END),
    MAX(CASE WHEN TableauCol = 2 THEN IIF(FaceUp, Label, '▒') ELSE '' END),
    MAX(CASE WHEN TableauCol = 3 THEN IIF(FaceUp, Label, '▒') ELSE '' END),
    MAX(CASE WHEN TableauCol = 4 THEN IIF(FaceUp, Label, '▒') ELSE '' END),
    MAX(CASE WHEN TableauCol = 5 THEN IIF(FaceUp, Label, '▒') ELSE '' END),
    MAX(CASE WHEN TableauCol = 6 THEN IIF(FaceUp, Label, '▒') ELSE '' END),
    MAX(CASE WHEN TableauCol = 7 THEN IIF(FaceUp, Label, '▒') ELSE '' END)
FROM Deck, won
WHERE TableauCol IS NOT NULL
AND not won
GROUP BY TableauRow

UNION ALL
-- Victory message display
SELECT '♠', '♣', '♥', '♦', '♠', '♣', '♥', '♦' FROM won WHERE won
UNION ALL
SELECT 'ᴥ', 'W', 'I', 'N', 'N', 'E', 'R', 'ᴥ' FROM won WHERE won
UNION ALL
SELECT '♥', '♦', '♠', '♣', '♥', '♦', '♠', '♣' FROM won WHERE won;