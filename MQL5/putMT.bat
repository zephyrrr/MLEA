choice /M "ÊÇ·ñ¸´ÖÆµ½Program Files\MetaTrader?£¿"
if ERRORLEVEL 2 goto end

xcopy /y /s /EXCLUDE:exclude.txt .\Include "D:\Program Files\MetaTrader 5\MQL5\Include" 
xcopy /y /s /EXCLUDE:exclude.txt .\Experts "D:\Program Files\MetaTrader 5\MQL5\Experts" 
xcopy /y /s /EXCLUDE:exclude.txt .\Scripts "D:\Program Files\MetaTrader 5\MQL5\Scripts" 

xcopy /y /s /EXCLUDE:exclude.txt .\Include "D:\Program Files\MetaTrader 5 - 2\MQL5\Include" 
xcopy /y /s /EXCLUDE:exclude.txt .\Experts "D:\Program Files\MetaTrader 5 - 2\MQL5\Experts" 
xcopy /y /s /EXCLUDE:exclude.txt .\Scripts "D:\Program Files\MetaTrader 5 - 2\MQL5\Scripts" 

: end
pause