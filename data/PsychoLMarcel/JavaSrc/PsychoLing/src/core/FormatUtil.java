package util;

public class FormatUtil {
	
	public static int[] intToBitB(int i)
	{
		int log2 = (int)(Math.log(i)/Math.log(2));
		int rest = i;
		
		int[] ret_A = new int[log2 + 1];
		
		while(true)
		{
			ret_A[log2] = 1;
			
			rest = rest - (int)Math.pow(2, log2);
			
			log2 = (int)(Math.log(rest)/Math.log(2));
			
			if(rest == 1)
			{
				ret_A[0] = rest;
				break;
			}
			if(rest == 0) break;
		}
		
		return ret_A;
	}
	
	public static double cutDecimal(double d, int n)
	{
		return (double)((int)(d * Math.pow(10,n)))/Math.pow(10, n);
	}

}
