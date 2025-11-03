# skid_buffer
-- Skid Buffer is the smallest buffer which can be used between two pipeline stages. It isolates the ready/stall path to relax timi ng. It acts like an elastic buffer which stores the valid data when the receiver applies backpressure to the sender.

-- Pipeline Skid Buffer can be used as the smallest buffer (depth-2) between pipeline stages, with complete isolation of valid & ready for better timing relaxation at slightly increased area cost.

Source codes included
---------------------
-- Skid Buffer

-- Pipeline Skid Buffer

License
--------
All codes are fully synthesizable and tested. All are open-source codes, free to use, modify and distribute without any conflicts of interest with the original developer.

Developer
---------
Mitu Raj, iammituraj@gmail.com, chip@chipmunklogic.com
