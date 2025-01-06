# Writing the improved README content to a .md file
improved_readme_content = """
# Digital Systems Lab

This repository contains Verilog code for the lab assignments of the Digital Systems course. The designs were simulated using **ModelSim** software and implemented on the **Zynq-7000 SoC** board using **Xilinx Vivado**.

---

## 📂 Repository Structure
The project is organized into several folders for clarity and ease of use:

- **`common/`**  
  Contains shared resources such as:
  - **Constraints file:** Used across all labs.
  - **Top module:** A reusable top-level design.
  - **Hex-to-7-segment decoder:** A common module used in multiple labs.

- **`LabXX/`**  
  Each lab folder is named according to the corresponding lab session (e.g., `Lab1`, `Lab3`, `Lab4`, etc.) and contains:
  - **`hdl/`**: Verilog source files specific to the lab.
  - Supporting documents, such as lab instructions and agendas.

---

## 🛠️ Tools Used
- **ModelSim**: For Verilog simulation and functional verification.
- **Xilinx Vivado**: For synthesis, implementation, and programming on the Zynq-7000 SoC board.