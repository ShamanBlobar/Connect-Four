local ROW_COUNT = 6
local COLUMN_COUNT = 7
local IN_A_ROW = 5

local function createBoard(rows, columns)
    local board = {}
    for _=1, rows do
        local section = {}
        for _=1, columns do
            section[#section+1] = "O"
        end
        board[#board+1] = section
    end
    return board
end

local function printBoard(board)
    local res = ""
    for _, row in pairs(board) do
        local section = "\x1B[0;38;5;31m|\x1B[0;0m"
        for _, elem in pairs(row) do
            if elem == 1 then
                elem = "\x1B[0;38;5;196m ["..elem.."] \x1B[0;0m"
            elseif elem == 2 then
                elem = "\x1B[0;33m ["..elem.."] \x1B[0;0m"
            else
                elem = "\x1B[0;38;5;25m ["..elem.."] \x1B[0;0m"
            end
            section = section..elem
        end
        section = section.."\x1B[0;38;5;31m|\x1B[0;0m\n"
        res = res..section
    end
    print(res)
end

local function getDropCoordinate(board, column, depth)
    for i=depth, 1, -1 do
        if board[i][column] == "O" then
            return i, column
        end
    end
    return nil
end

local function dropPiece(board, col, dep, turn)
    if turn then
        board[col][dep] = 1
    else
        board[col][dep] = 2
    end
end

local function isBoardFull(board)
    for _, row in pairs(board) do
        for _, space in pairs(row) do
            if space == "O" then
                return false
            end
        end
    end
    return true
end

local function horizontalSearch(board, depth, symbol, required)
    local inRow = 0
    for _, space in ipairs(board[depth]) do
        if space == symbol then
            inRow = inRow + 1
            if inRow == required then
                return true
            end
        else
            inRow = 0
        end
    end
    return false
end

local function verticalSearch(board, column, symbol, required)
    local inRow = 0
    for _, row in ipairs(board) do
        if row[column] == symbol then
            inRow = inRow + 1
            if inRow == required then
                return true
            end
        else
            inRow = 0
        end
    end
    return false
end

local function diagonalSearch(board, column, depth, symbol, required)
    local inRow = 1
    local function add(a, b) return a+b end
    local function sub(a, b) return a-b end
    local operatorOrder = {{add, add}, {sub, sub}, {add, sub}, {sub, add}}
    for o=1, 4 do
        for i=1, required*2 do
            if board[operatorOrder[o][1](depth, i)] and board[operatorOrder[o][2](column, i)] then
                if board[operatorOrder[o][1](depth, i)][operatorOrder[o][2](column, i)] == symbol then
                    inRow = inRow + 1
                    if inRow == required then
                        return true
                    end
                else
                    inRow = 1
                end
            end
        end
    end
    return false
end

local function isWon(board, depth, column, turn, required)
    local symbol = 1
    if not turn then symbol = 2 end
    if horizontalSearch(board, depth, symbol, required) or verticalSearch(board, column, symbol, required) or diagonalSearch(board, column, depth, symbol, required) then
        return true
    end
    return false
end

local gameBoard = createBoard(ROW_COUNT, COLUMN_COUNT)
local outcome = "Tie!"
local gameOver = false
local turn = true
local turnNum = 1

while not gameOver do
    os.execute("cls")
    printBoard(gameBoard)
    if turn then turnNum = 1 else turnNum = 2 end
    local turnOver = false
    while not turnOver do
        print("PLAYER "..turnNum.."'s turn\nPick a column [1-"..COLUMN_COUNT.."] to place your piece ["..turnNum.."] into.")
        local pickedColumn = tonumber(io.read())
        if getDropCoordinate(gameBoard, pickedColumn, ROW_COUNT) then
            turnOver = true
            local dep, col = getDropCoordinate(gameBoard, pickedColumn, ROW_COUNT)
            dropPiece(gameBoard, dep, col, turn)
            if isWon(gameBoard, dep, col, turn, IN_A_ROW) then

                outcome = "PLAYER "..turnNum.." WINS!"
                gameOver = true
            end
        else
            os.execute("cls")
            printBoard(gameBoard)
            print("You can't place a piece here.")
        end
    end
    if isBoardFull(gameBoard) then
        gameOver = true
    end
    turn = not turn
end

os.execute("cls")
printBoard(gameBoard)
print(outcome)