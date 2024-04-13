import Text.Printf

-- recebe um comando e devolve a posição final
basico :: Command -> (Int, Int, Direcao, [Command]) 
basico (Forward n) = (0, n, Norte, [])               -- se comando foi Forward, incrementa y
basico (Backward n) = (0, -n, Norte, [])             -- se comando foi Backward, decrementa y
basico TurnLeft = (0, 0, Oeste, [])       
basico TurnRight = (0, 0, Leste, [])

-- posicionar recebe posição atual, direção e lista de comandos 
-- e devolve posição final, direção e lista de comandos
posicionar :: (Int, Int, Direcao, [Command]) -> (Int, Int, Direcao, [Command])
-- caso base: sem comandos, permanecer na posição recebida
posicionar (x, y, direcao, []) = (x, y, direcao, []) 
-- se estiver olhando para o norte e for para a frente, incrementa y
posicionar (x, y, Norte, (Forward n):xs) = posicionar (x, y+n, Norte, xs)
-- se estiver olhando para o norte e for para trás, decrementa y
posicionar (x, y, Norte, (Backward n):xs) = posicionar (x, y-n, Norte, xs)
-- se estiver olhando para o sul e for para a frente, decrementa y
posicionar (x, y, Sul, (Forward n):xs) = posicionar (x, y-n, Sul, xs)
-- se estiver olhando para o sul e for para trás, incrementa y
posicionar (x, y, Sul, (Backward n):xs) = posicionar (x, y+n, Sul, xs)
-- se estiver olhando para o leste e for para a frente, incrementa x
posicionar (x, y, Leste, (Forward n):xs) = posicionar (x+n, y, Leste, xs)
-- se estiver olhando para o leste e for para trás, decrementa x
posicionar (x, y, Leste, (Backward n):xs) = posicionar (x-n, y, Leste, xs)
-- se estiver olhando para o oeste e for para a frente, decrementa x
posicionar (x, y, Oeste, (Forward n):xs) = posicionar (x-n, y, Oeste, xs)
-- se estiver olhando para o oeste e for para trás, incrementa x
posicionar (x, y, Oeste, (Backward n):xs) = posicionar (x+n, y, Oeste, xs)

-- Ex.: Norte + TurnLeft = Oeste
posicionar (x, y, Norte, (TurnLeft):xs) = posicionar (x, y, Oeste, xs)
posicionar (x, y, Norte, (TurnRight):xs) = posicionar (x, y, Leste, xs)
posicionar (x, y, Sul, (TurnLeft):xs) = posicionar (x, y, Leste, xs)
posicionar (x, y, Sul, (TurnRight):xs) = posicionar (x, y, Oeste, xs)
posicionar (x, y, Leste, (TurnLeft):xs) = posicionar (x, y, Norte, xs)
posicionar (x, y, Leste, (TurnRight):xs) = posicionar (x, y, Sul, xs)
posicionar (x, y, Oeste, (TurnLeft):xs) = posicionar (x, y, Sul, xs)
posicionar (x, y, Oeste, (TurnRight):xs) = posicionar (x, y, Norte, xs)

data Direcao = Norte | Sul | Leste | Oeste       -- para onde o robô pode estar olhando
  deriving (Show)
data Command = Forward Int | Backward Int | TurnLeft | TurnRight  -- comandos possíveis
  deriving (Show)
destination :: [Command] -> (Int, Int, Direcao, [Command]) 
destination [] = (0, 0, Norte, [])    -- caso base: sem comandos, permanecer na posição original
destination (x:[]) = basico x         -- caso básico: apenas um comando foi recebido
destination (x:xs) = posicionar (0, 0, Norte, (x:xs)) -- caso composto: chama função posicionar

arvore :: String
arvore = "#"
rua :: String
rua = " " 
escola :: String
escola = "@"
alunoNorte :: String
alunoNorte = "^"
alunoSul :: String
alunoSul = "v"
alunoLeste :: String
alunoLeste = ">"
alunoOeste :: String
alunoOeste = "<"

montagem1 :: [[String]]
montagem1 = [[arvore, arvore, rua, escola], [arvore, arvore, rua, arvore], [arvore, arvore, rua, arvore], [arvore, alunoNorte, rua, arvore]]

printLinha :: [String] -> IO ()
printLinha linha = printf "|%-3s%-3s%-3s%-3s|\n" (linha!!0) (linha!!1) (linha!!2) (linha!!3)


cenario :: [[String]] -> IO ()
cenario (x:y:z:t:_) = do
  printf " ____________\n"
  printLinha x
  printLinha y
  printLinha z
  printLinha t
  printf " ____________\n"

trataSimples :: Command -> [[String]] -> [[String]]
trataSimples TurnLeft montagem = map (map (\x -> if x == alunoNorte then alunoLeste else if x == alunoSul then alunoLeste else if x == alunoLeste then alunoNorte else alunoSul)) montagem

trataComando :: Command -> [[String]] -> [[String]]
trataComando TurnLeft montagem = trataSimples TurnLeft montagem1
trataComando TurnRight montagem = trataSimples TurnRight montagem


menu :: IO Command
menu = do
  putStrLn "\nOpções:"
  putStrLn "\n[1] Para Frente \t\t[2] Para Trás"
  putStrLn "\n[3] Virar à Esquerda \t[4] Virar à Direita"
  putStrLn "\nEscolha um comando:"
  comandoStr <- getLine                
  let comando = read comandoStr :: Int
  if comando == 1 || comando == 2 then do
    putStrLn "\nQuantos passos?"
    passosStr <- getLine
    let passos = read passosStr :: Int
    if comando == 1 then 
      return (Forward passos)
    else 
      return (Backward passos)
  else 
    if comando == 3 then 
      return TurnLeft
    else 
      return TurnRight

jogo :: [[String]] -> IO()
jogo montagem = do
  cenario montagem
  comando <- menu
  trataComando comando montagem
  cenario 
  
main = do
  putStrLn "-- Seja bem-vinda(o) ao jogo Chegando ao CI! --"
  putStrLn "\nFase 1:"
  jogo montagem1
  
  
  --print(destination [TurnLeft, Backward 3, TurnRight, TurnRight, Forward 4])
  --putStrLn "\128187"
