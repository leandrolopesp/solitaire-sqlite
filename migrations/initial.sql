/* 
 SPDX-License-Identifier: CC-BY-NC-4.0
 Copyright (c) Leandro Lopes Pereira. Some rights reserved.
 See LICENSE file for full details.
*/

-- This script creates and inserts shuffled cards into the Deck table, positioning them on the tableau.
-- This is an educational script. Start the game with:

-- insert into moves(action) values('new');

-- This command triggers trgNewGame.
-- This trigger does the same as this query, but without it's elegance.

WITH 
    -- Recursive sequence to generate values from 1 to 13
    -- These numbers will represent cards from A to K and also positions on the game tableau
    RECURSIVE Seq (value) AS (
        SELECT 1         -- Anchor member
        UNION ALL        -- Combines anchor with recursive member
        SELECT value + 1 -- Step member
        FROM Seq         -- Recursive member
        WHERE value < 13 -- Stop condition
    ),

    Suits(Suit) AS (VALUES ('♠'), ('♣'), ('♥'), ('♦')), -- Insert suits using tuples

    -- Create cards with suits and values, already shuffled
    Cards AS (
        SELECT  Suit,
                Value Rank,
                ROW_NUMBER() OVER (ORDER BY random()) AS SortOrder -- Generates random ordering for cards
        FROM    Seq, Suits -- Cross Join, combines all values with all suits
    ),

    -- On the tableau, each card is represented by a column and row combination
    -- Column represents horizontal position, row represents vertical position
    -- Cards are distributed in a 7-column grid
    -- Initially, revealed cards are the last ones in each column (same column and row numbers)

    Tableau AS (
        SELECT  col.value AS TableauCol,
                row.value AS TableauRow,
                ROW_NUMBER() OVER (ORDER BY col.value, row.value) AS TableauOrder, -- This ordering is used to associate cards with their positions
                (col.value = row.value) AS FaceUp -- SQLite boolean expressions return 0 and 1. No need for "CASE WHEN col.value = row.value THEN 1 ELSE 0 END"
        FROM    Seq col, Seq row -- combines numbers 1 to 7 for columns and rows
        WHERE   row.value <= col.value -- Ensures row doesn't exceed column, creating triangular tableau shape
        AND     col.value < 8 -- Limits to 7 columns, maximum number of tableau columns
    )

INSERT INTO Deck (Suit, Rank, SortOrder, TableauCol, TableauRow, FaceUp, IsWasteTop) 
SELECT  c.Suit, 
        c.Rank, 
        c.SortOrder, 
        t.TableauCol, 
        t.TableauRow, 
        t.FaceUp, 
        (c.SortOrder = 29) IsWasteTop -- Card with sort order 29 will be initially placed in player's hand (since there are 28 cards on tableau)
                                      -- We could get the lowest sort order not on tableau, but
                                      -- since the value is fixed, there's no need for that
FROM Cards c
LEFT JOIN Tableau t 
ON c.SortOrder = t.TableauOrder;


--Alternative method
/*
WITH RECURSIVE
     Seq(val) AS (SELECT 1 
                  UNION ALL 
                  SELECT val+1 
                  FROM seq 
                  WHERE val < 52), --Creates every card order
     Cards as(SELECT substr('♠♣♥♦', ((val - 1) % 4) + 1,1) Suit --uses module, the remainder of the division. Module 4 results in numbers from 0-3.
                   , ((val-1) % 13) + 1 Rank
                   , ROW_NUMBER() OVER (ORDER BY random()) AS SortOrder
              FROM Seq)
(...)
*/