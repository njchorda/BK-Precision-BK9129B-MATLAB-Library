classdef BK9129B
    properties
       serialPort;
       v;
    end
    
    methods
        function obj = BK9129B(varargin)
            if numel(varargin) == 0
                obj.serialPort = BK9129B.findAddress();
            else
                obj.serialPort = varargin{1};
            end
            obj.v = serialport(obj.serialPort, 9600);%, 'Terminator', 'CR/LF');
            % obj.v.
            obj.sendCommand('SYST:REM');
            obj.reset();
            obj.setVoltage(0, 0, 0);
        end
        
        function setOutput(obj, boo)
            if boo
                obj.sendCommand('OUTP:STAT 1');
            else
                obj.sendCommand('OUTP:STAT 0');
            end
        end

        function setVoltage(obj, varargin)
            % Sets the voltage of any channel. Set voltages in order of
            % channel, the position is the voltage of the corresponding
            % channel. i.e. to set channel 1 to 1V, 2 to 2V, and 3 to 3V,
            % use ps.setAllChannels(1, 2, 3). If you do not wish to change
            % the voltage on a channel, use [] (i.e. setAllChannels(1, [],)
            % If only changing channel 1, use ps.setAllChannels(1)
            switch numel(varargin)
                case 1
                    obj.sendCommand(['APP:VOLT ' num2str(varargin{1})]);
                case 2
                    if isempty(varargin{1})
                        [v1, ~, ~] = obj.getSetVoltage();
                    else
                        v1 = varargin{1};
                    end
                    if isempty(varargin{2})
                        [~, v2, ~] = obj.getSetVoltage();
                    else
                        v2 = varargin{2};
                    end
                    obj.sendCommand(['APP:VOLT ' num2str(v1), ',', num2str(v2)]);
                case 3
                    if isempty(varargin{1})
                        [v1, ~, ~] = obj.getSetVoltage();
                    else
                        v1 = varargin{1};
                    end
                    if isempty(varargin{2})
                        [~, v2, ~] = obj.getSetVoltage();
                    else
                        v2 = varargin{2};
                    end
                    if isempty(varargin{3})
                        [~, ~, v3] = obj.getSetVoltage();
                    else
                        v3 = varargin{3};
                    end
                    obj.sendCommand(['APP:VOLT ' num2str(v1), ',', num2str(v2), ',', num2str(v3)]);

            end

        end

        function [V1, V2, V3] = getSetVoltage(obj)
            resp = obj.sendCommand('SOUR:APP:VOLT?');
            splt = strsplit(resp, ',');
            V1 = str2double(strtrim(splt{1}));
            V2 = str2double(strtrim(splt{2}));
            V3 = str2double(strtrim(splt{3}));
        end

        function [I1, I2, I3] = getSetCurrent(obj)
            resp = obj.sendCommand('SOUR:APP:CURR?');
            splt = strsplit(resp, ',');
            I1 = str2double(strtrim(splt{1}));
            I2 = str2double(strtrim(splt{2}));
            I3 = str2double(strtrim(splt{3}));
        end

        function [V1, V2, V3] = getMeasuredVoltage(obj)
            resp = obj.sendCommand('MEAS:VOLT:ALL?');
            splt = strsplit(resp, ',');
            V1 = str2double(strtrim(splt{1}));
            V2 = str2double(strtrim(splt{2}));
            V3 = str2double(strtrim(splt{3}));
        end

        function [I1, I2, I3] = getMeasuredCurrent(obj)
            resp = obj.sendCommand('MEAS:CURR:ALL?');
            splt = strsplit(resp, ',');
            I1 = str2double(strtrim(splt{1}));
            I2 = str2double(strtrim(splt{2}));
            I3 = str2double(strtrim(splt{3}));
        end

        function [P1, P2, P3] = getMeasuredPower(obj)
            resp = obj.sendCommand('MEAS:POW? ALL');
            splt = strsplit(resp, ',');
            P1 = str2double(strtrim(splt{1}));
            P2 = str2double(strtrim(splt{2}));
            P3 = str2double(strtrim(splt{3}));
        end

        function setCurrentLimit(obj, varargin)
            switch numel(varargin)
                case 1
                    obj.sendCommand(['SOUR:APP:CURR ' num2str(varargin{1})]);
                case 2
                    if isempty(varargin{1})
                        [i1, ~, ~] = obj.getSetCurrent();
                    else
                        i1 = varargin{1};
                    end
                    if isempty(varargin{2})
                        [~, i2, ~] = obj.getSetCurrent();
                    else
                        i2 = varargin{2};
                    end
                    obj.sendCommand(['SOUR:APP:CURR ' num2str(i1), ',', num2str(i2)]);
                case 3
                    if isempty(varargin{1})
                        [i1, ~, ~] = obj.getSetCurrent();
                    else
                        i1 = varargin{1};
                    end
                    if isempty(varargin{2})
                        [~, i2, ~] = obj.getSetCurrent();
                    else
                        i2 = varargin{2};
                    end
                    if isempty(varargin{3})
                        [~, ~, i3] = obj.getSetCurrent();
                    else
                        i3 = varargin{3};
                    end
                    obj.sendCommand(['SOUR:APP:CURR ' num2str(i1), ',', num2str(i2), ',', num2str(i3)]);

            end
        end

        function setLocal(obj)
            obj.sendCommand(obj.v, 'SYST:LOC');
        end
        
        function retVal = sendCommand(obj, command)
            if contains(command, '?') == 1
                writeline(obj.v, command);
                retVal = readline(obj.v);
            else
                writeline(obj.v, command);
                retVal = 0;
            end
        end
        
        function reset(obj)
            obj.sendCommand('*RST');
            obj.setVoltage(0, 0, 0);
            obj.setCurrentLimit(0, 0, 0);
        end
        
        function selfTest(obj)
           retStr = obj.sendCommand('*TST?');
           try ret = str2double(retStr);
           catch 
               error('Non-numerical response')
           end
           if(ret == 0)
               disp(['No errors found in self-test, code:' num2str(ret)]);
           else
               disp(['Error code: ' ret]);
           end
        end            
        
        function bool = deInit(obj)
            if(isvalid(obj.v) == 1)
                obj.sendCommand('SYST:LOC');
                obj.reset();
                clear obj.v;
                bool = 1;
            else
                bool = 0;
            end

        end
    end
        methods (Static)
        function address = findAddress()
            ports = serialportlist();
            address = ports;
        end
    end
end