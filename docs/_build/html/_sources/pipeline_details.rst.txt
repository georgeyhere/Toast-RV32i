.. _pipeline_details:

Pipeline Details
================

.. figure:: images/toast_architecture.jpg
    :name: toast_architecture
    :align: center

Toast has a classic 5-stage pipeline with the following stages:

Instruction Fetch (IF)
    Fetches instruction from memory via the Instruction Memory interface. Requires one cycle to execute. See :ref:`instruction_fetch` for details.

Instruction Decode (ID)
	Decodes the fetched instruction, generates control signals, and fetches register file data for decoded instruction. Outputs are registered, stage requires one cycle to execute. See :ref:`instruction_decode` for details.

Execute (EX)
    Muxes the correct operands into the ALU and performs operation based on control signals. Outputs are registered, stage requires one cycle to execute. See :ref:`execute` for details.

Memory Access (MEM)
	All loads and stores are handled in this stage. See :ref:`mem` for details.

Writeback (WB)
	For now serves as a simple pass through back to the register file, containing only a single mux that controls whether memory data or the ALU result is written. 


Pipeline Control
----------------
Pipeline forwarding and stalls are handled by a separate control module (:file:`rtl/toast_control`). The control module is composed of combinatorial logic and checks for data hazards in the EX and MEM stages. 
