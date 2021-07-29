.. _instruction_decode:

Instruction Decode Stage (ID)
=============================

.. figure:: images/toast_ID_simple.jpg
    :name: id_simple
    :align: center

The Instruction Decode stage (:file:`rtl/toast_ID_stage`) is comprised of the Decoder block and the Register File. It decodes the instruction fetched in the IF stage, fetches register file data based on the decoded addresses, and registers its outputs.


Decoder:
--------

The decoder (:file:`rtl/toast_decoder`) processes an uncompressed instruction and decodes it into the control signals needed to execute the instruction. This includes immediates, register file addresses, ALU operation control, Branch Gen operation control, and Memory operation. The decoder is comprised of only combinatorial logic.

The decoder also sets **ID_jump_en_o** if an unconditional jump (JAL or JALR) is decoded. All conditional branches are assumed to be not taken until processed in the EX stage.


Register File:
--------------

The register file (:file:`toast_regfile`) contains 32 32-bit registers. It is implemented using RAM32M primitives and has no reset function, so a reset routine is needed in software. An alternative flip-flop implementation is commented out that does have a synchronous active-low reset if the user requires it.

The register file has two read ports for rs1 and rs2 and one write port for rd. Data is written into rd on the rising edge of the clock. rs1 and rs2 can be read from on the same cycle that a read is requested.



