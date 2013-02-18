net use \\192.168.0.10 2011@zs /user:administrator

rem copy x64\Release-X64\MLEA.* "D:\Program Files\MetaTrader 5\MQL5\Libraries"
rem copy x64\Release-X64\MLEA.* "\\192.168.0.10\d$\Program Files\MetaTrader 5\MQL5\Libraries"
copy x64\Debug-X64\MLEA.* "D:\Program Files\MetaTrader 5\MQL5\Libraries"
copy x64\Debug-X64\MLEA.* "\\192.168.0.10\d$\Program Files\MetaTrader 5\MQL5\Libraries"

copy x64\Debug-X64\MLEA.* "\\192.168.0.10\e$\MyTest\Debug-X64"
copy x64\Release-X64\MLEA.* "\\192.168.0.10\e$\MyTest\Release-X64"

copy "D:\Program Files\MetaTrader 5\MQL5\Experts\MyExpertModel.ex5" "\\192.168.0.10\d$\Program Files\MetaTrader 5\MQL5\Experts"
copy "D:\Program Files\MetaTrader 5\MQL5\Experts\OrderTxtExpert.ex5" "\\192.168.0.10\d$\Program Files\MetaTrader 5\MQL5\Experts"

pause