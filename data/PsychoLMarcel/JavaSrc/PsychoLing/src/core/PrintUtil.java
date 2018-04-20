package util;

import java.util.ArrayList;
import java.util.TreeSet;

public class PrintUtil {
	
	public static void printAugment(int i, int j, TreeSet<Integer> SU, TreeSet<Integer> LV, TreeSet<Integer> SV, int[] pred, double[] pj)
	{
		StringBuilder sb = new StringBuilder();
		
		sb.append("i: " + i + " ");
		sb.append("j: " + j + " ");
		sb.append("SU: {");
		for(Integer in: SU)
		{
			sb.append(in+",");
		}
		sb.append("}");
		
		sb.append("LV: {");
		for(Integer in: LV)
		{
			sb.append(in+",");
		}
		sb.append("}");
		
		sb.append("SV: {");
		for(Integer in: SV)
		{
			sb.append(in+",");
		}
		sb.append("}");
		
		sb.append("pred: [");
		for(int k=0; k<pred.length; k++)
		{
			sb.append(","+pred[k]);
		}
		sb.append("]");
		
		sb.append("pj: [");
		for(int k=0; k<pred.length; k++)
		{
			sb.append(","+pj[k]);
		}
		sb.append("]");
		
		System.out.println(sb.toString());
		
	}
	
	public static String printArray(double[] array, boolean row)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.length-1; i++)
		{
			if(row)
			{
				sb.append(array[i] + ", ");
			}
			else
			{
				sb.append(array[i] + "\n");
			}
		}
		if(row)
		{
			sb.append(array[array.length-1]);
		}
		else
		{
			sb.append(array[array.length-1] + "\n");
		}
		
		return sb.toString();
	}
	
	public static String printArray(Double[] array, boolean row)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.length; i++)
		{
			if(row)
			{
				sb.append(array[i] + ", ");
			}
			else
			{
				sb.append(array[i]);
			}
		}
		
		return sb.toString();
	}
	
	public static void printArray(double[] array, String[] label, boolean row)
	{
		for(int i=0; i<array.length; i++)
		{
			if(row)
			{
				System.out.print(label[i] + ": " + array[i] + " ");
			}
			else
			{
				System.out.println(label[i] + ": " + array[i]);
			}
		}
	}
	
	public static String printArray(int[] array, boolean row)
	{
		if(array.length > 0)
		{
			StringBuffer sb = new StringBuffer();
			
			for(int i=0; i<array.length-1; i++)
			{
				if(row)
				{
					sb.append(array[i] + ",");
				}
				else
				{
					sb.append(array[i] + ",\n");
				}
			}
			if(row)
			{
				sb.append(array[array.length-1]);
			}
			else
			{
				sb.append(array[array.length-1] + "\n");
			}
			
			return sb.toString();
		}
		
		return "";
	}
	
	public static String printArray(String[] array, boolean row)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.length; i++)
		{
			if(row)
			{
				sb.append(array[i] + ",");
			}
			else
			{
				sb.append(array[i] + ",\n");
			}
		}
		
		return sb.toString();
	}
	
	public static String print2DArray(int[][] array)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.length; i++)
		{
			for(int j=0; j<array[i].length; j++)
			{
				sb.append(array[i][j] + " | ");
			}
			sb.append("\n");
		}
		
		return sb.toString();
	}
	
	public static String printIntArrayList(ArrayList<int[]> array)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.size(); i++)
		{
			for(int j=0; j<array.get(i).length; j++)
			{
				sb.append(array.get(i)[j] + " | ");
			}
			sb.append("\n");
		}
		
		return sb.toString();
	}
	
	public static String printArrayList(ArrayList<Integer> array)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.size(); i++)
		{
			sb.append(array.get(i)+ " | ");
		}
		
		return sb.toString();
	}
	
	public static String printStringArrayList(ArrayList<String> array)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.size(); i++)
		{
			sb.append(array.get(i) + " | ");
			sb.append("\n");
		}
		
		return sb.toString();
	}
	
	public static String print2DArray(double[][] array)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.length; i++)
		{
			for(int j=0; j<array[i].length; j++)
			{
				sb.append(array[i][j] + " | ");
			}
			sb.append("\n");
		}
		
		return sb.toString();
	}
	
	public static String print2DArray(Double[][] array)
	{
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<array.length; i++)
		{
			for(int j=0; j<array[i].length; j++)
			{
				sb.append(array[i][j] + " | ");
			}
			sb.append("\n");
		}
		
		return sb.toString();
	}
	
	public static String print2DAtoMatlabMatrix(double[][] array)
	{
		StringBuffer sb = new StringBuffer();
		
		sb.append("m=[");
		for(int j=0; j<array[0].length; j++)
		{
			for(int i=0; i<array.length; i++)
			{
				sb.append(array[i][j] + " ");
			}
			sb.append(";\n");
		}
		sb.append("]");
		
		return sb.toString();
	}

}
