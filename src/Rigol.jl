module Rigol

import PyCall: pyimport

export get_ch_data, single


function get_resource_manager(path="/usr/lib/librsvisa.so")
  visa = try
    pyimport("pyvisa")
  catch
    error("could not load pyvisa")
  end
  return visa.ResourceManager(path)
end


function open(addr, rm)
  rm.open_resource(addr)
end

# e.g. addr = "TCPIP::192.168.1.2::INSTR"
function open(addr)
  rm = get_resource_manager()
  rm.open_resource(addr)
end

function _data_to_values(data, params;)
  format, typo, num_points, count, x_incr, x_orig, x_ref, y_incr, y_orig, y_ref = params
  a = 1:num_points
  xs = @. ((a - x_ref- x_orig) * x_incr) 
  # ys = @. ((data) * y_incr) #+ y_orig
  ys = @. ((data - y_ref- y_orig) * y_incr) 
  return [xs, ys]
end

function _set_source_channel(osc, ch)
  osc.write("WAV:SOURCE CHAN$ch")
  sleep(0.01)
end

function _get_source_params(osc)
  osc.query_ascii_values("WAV:preamble?")
end

function _get_binary_data(osc)
  sleep(0.01)
  osc.query_binary_values("WAV:DATA?", datatype="B", is_big_endian=true)
end


function single(osc)
  osc.write("SING")
end

function get_ch_data(osc, channel)
  _set_source_channel(osc, channel)
  params = _get_source_params(osc)
  bin = _get_binary_data(osc)
  return _data_to_values(bin, params)
end


end
