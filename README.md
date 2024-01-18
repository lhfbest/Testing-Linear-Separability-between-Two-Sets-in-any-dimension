# Testing-Linear-Separability-between-Two-Sets-in-any-dimension

**It is based on paper: "Shuiming Zhong and Huan Lyu, 'A New Sufficient & Necessary Condition for Testing Linear Separability between Two Sets', TPAMI 2024."
Please kindly remember to cite this reference if it is utilized.**

**This code can be used to quickly determine the linear separability between two sets in any dimension. A GPU is required.**

![LS](https://github.com/lhfbest/Determine-the-linear-separability-between-two-sets-in-any-dimension/assets/47107649/94f2e066-707a-407a-b306-10617608b1ed)
`Fig. 1 Example of two sets being linearly separable`

![NLS](https://github.com/lhfbest/Determine-the-linear-separability-between-two-sets-in-any-dimension/assets/47107649/af9e4a1f-f0e7-4637-9538-c42a12690d5d)
`Fig. 2 Example of two sets that are non linearly separable`

**This code is implemented solely to verify the feasibility of the algorithm presented in the paper. 
There are many aspects where efficiency can be further optimized. Your corrections and suggestions are most welcome!**

NOTES:
  - After downloading the folder, you can run the LS_Testing_Demo.m directly in the matlab environment. 
  - A GPU is required. If the matlab version is too low (the code is written under matlab2023), an error may be reported.
  - The Demo provides two operating modes. One is to generate two point sets A and B from the code to test their linear separability (for a quick try). The other is to import local data to determine linear separability. Dimension10_Size5000_LS.csv is the sample data. Detailed input data specifications can be found in the instructions in LS_Tesing.


The author's research interests include machine learning, classification problems, clustering problems, etc. Exchange and collaboration are welcome.

Contact Information 1: huanlyu@nuist.edu.cn    

Contact Information 2: 1726341330@qq.com

Creation Date: 2024-01-17

Last Modified Date: 2024-01-18





