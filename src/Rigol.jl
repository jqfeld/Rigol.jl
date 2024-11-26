module Rigol


export get_ch_data, single

struct Oscilloscope{P}
  port::P
end

function write(osc::Oscilloscope, str; termination="\n")
  Base.write(osc.port, str * termination)
end

#TODO: add timeout with `Base.timedwait`
function read_ascii(osc::Oscilloscope)
  readline(osc.port)
end


function query_ascii(osc, query; termination="\n")
  write(osc, query; termination)
  return read_ascii(osc)
end

function query_ascii_values(osc, query; delim=",", type=Float64, kwargs...)
  str = query_ascii(osc, query; kwargs...)
  parse.(type, split(str, delim))
end


function parse_ieee_header(data)
  start = findfirst(==(0x23), data)
  header_length = parse(Int, Char(data[2]))
  offset = start + header_length + 2
  buffer_length = parse(Int, String(data[3:(start+1+header_length)]))
  return offset, buffer_length
end

#HACK: this needs to be implemented more robust, also allow for non-UInt8 data
function query_binary_values(osc, query; termination="\n",)
  write(osc, query; termination)
  bytes = Base.readavailable(osc.port)
  if bytes[end] == 0x0a
    pop!(bytes)
  end
  offset, data_length = parse_ieee_header(bytes)
  return bytes[offset:(offset+data_length-1)]
end



# function get_resource_manager(path="/usr/lib/librsvisa.so")
#   visa = try
#     pyimport("pyvisa")
#   catch
#     error("could not load pyvisa")
#   end
#   return visa.ResourceManager(path)
# end
#
#
# function open(addr, rm)
#   rm.open_resource(addr)
# end
#
# # e.g. addr = "TCPIP::192.168.1.2::INSTR"
# function open(addr)
#   rm = get_resource_manager()
#   rm.open_resource(addr)
# end

function _data_to_values(data, params;)
  format, typo, num_points, count, x_incr, x_orig, x_ref, y_incr, y_orig, y_ref = params
  a = 1:num_points
  xs = @. ((a - x_ref- x_orig) * x_incr) 
  # ys = @. ((data) * y_incr) #+ y_orig
  ys = @. ((data - y_ref- y_orig) * y_incr) 
  return [xs, ys]
end

function _set_source_channel(osc, ch)
  write(osc,"WAV:SOURCE CHAN$ch")
  sleep(0.01)
end

function _get_source_params(osc)
  query_ascii_values(osc,"WAV:preamble?")
end

function _get_binary_data(osc)
  sleep(0.01)
  query_binary_values(osc,"WAV:DATA?")
end


function single(osc)
  write(osc, "SING")
end

function get_ch_data(osc, channel)
  _set_source_channel(osc, channel)
  params = _get_source_params(osc)
  bin = _get_binary_data(osc)
  return _data_to_values(bin, params)
end


end
