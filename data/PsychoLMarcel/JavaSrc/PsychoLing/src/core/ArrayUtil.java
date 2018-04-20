package util;

import java.util.ArrayList;
import java.util.HashMap;

public class ArrayUtil {
	
//	public static ArrayList<int[][]> powerSet(int[] set)
//	{
//		int[][] nSet = new int[1][];
//		nSet[0] = set;
//		
//		ArrayList<int[][]> ret_L = new ArrayList<>();
//		
//		ret_L.add(nSet);
//		
//		powerSetRec(nSet, ret_L, set.length);
//		
//		return ret_L;
//	}
//	
//	private static void powerSetRec(int[][] set, ArrayList<int[][]> ret_L, int k)
//	{
//		if(k > 1){
//		for(int[] iA: set)
//		{
//			int[][] pSetP = subsets(iA);
//			ret_L.add(pSetP);
//			
//			powerSetRec(pSetP, ret_L, k-1);
//		}}	
//	}
//	
//	public static int[][] subsets(int[] set)
//	{
//		int[][] ret_A = new int[set.length][set.length-1];
//		
//		int c1, c2;
//		
//		for(int i=0; i<set.length; i++)
//		{
//			c1=0;
//			c2=0;
//			for(int j=0; j<set.length; j++)
//			{
//				if(c2 != i)
//				{
//					ret_A[i][c1] = set[c2];
//					c1++;
//				}					
//				c2++;
//			}
//		}
//		return ret_A;
//	}
	
	public static ArrayList<int[][]> powerSet(int[] set)
	{
		ArrayList<int[][]> ret_L = new ArrayList<>();
		
		HashMap<Integer, Integer> elToIndex = new HashMap<>();
		
		for(int i=0; i<set.length; i++)
		{
			elToIndex.put(set[i], i);
		}
		
		int subL;
		int[][] nextLevel;
		
		nextLevel = new int[set.length][1];
		ret_L.add(nextLevel);
		//init first Level
		
		for(int i=0; i<set.length; i++)
		{
			nextLevel[i][0] = set[i];
		}
		
		for(int i=1; i<set.length; i++)
		{
			subL = (int)MathUtil.nChoosek(set.length, (i+1));
			nextLevel = new int[subL][i+1];
			ret_L.add(nextLevel);
			
			int c = 0;
			
			for(int j=0; j< ret_L.get(i-1).length; j++)
			{
				int[] currS = ret_L.get(i-1)[j];
//System.out.println(PrintUtil.printArray(currS, true));				
				for(int k=elToIndex.get(currS[currS.length-1])+1; k<set.length; k++)
				{				
					for(int l=0; l<currS.length; l++)
					{
//System.out.println(c + " " + l + " " + k);	
						nextLevel[c][l] = currS[l];
//System.out.println("nextL: " + PrintUtil.print2DArray(nextLevel));
					}
					nextLevel[c][currS.length] = set[k];
					c++;
				}
			}
		}
		
		return ret_L;
	}
	
	public static int[] copy(int[] a)
	{
		int[] a_A = new int[a.length];
		
		for(int i=0; i<a.length; i++)
		{
			a_A[i] = a[i];
		}
		
		return a_A;
	}
	
	public static int[][] copy(int[][] aa)
	{
		int[][] aa_AA = new int[aa.length][];
		
		for(int i=0; i<aa_AA.length; i++)
		{
			aa_AA[i] = new int[aa[i].length];
			
			for(int j=0; j<aa_AA[i].length; j++)
			{
				aa_AA[i][j] = aa[i][j];
			}
		}
		
		return aa_AA;
	}
	
	public static double sum(double[] a)
	{
		double sum = 0;
		
		for(int i=0; i<a.length; i++)
		{
			sum = sum + a[i];
		}
		return sum;
	}
	
	public static double sum(double[][] a)
	{
		double sum = 0;
		
		for(int i=0; i<a.length; i++)
		for(int j=0; j<a[i].length; j++)
		{
			sum = sum + a[i][j];
		}
		return sum;
	}
	
	public static int sum(int[] a)
	{
		int sum = 0;
		
		for(int i=0; i<a.length; i++)
		{
			sum = sum + a[i];
		}
		return sum;
	}
	
	public static double sum(double[] a, int s, int e)
	{
		double sum = 0;
		
		for(int i=s; i<e; i++)
		{
			sum = sum + a[i];
		}
		return sum;
	}
	
	public static int numArrayElements(int[][] aa)
	{
		int retV = 0;
		
		for(int i=0; i<aa.length; i++)
		{
			retV = retV + aa[i].length;
		}
		
		return retV;
	}
	
	public static int indexOfMin(double[] a)
	{
		int minIndex = 0;
		double minValue = Double.NEGATIVE_INFINITY;
		
		for(int i=0; i<a.length; i++)
		{
			if(minValue > a[i])
			{
				minValue = a[i];
				minIndex = i;
			}
		}
		return minIndex;
	}

	/**
	 * a is the permutation to transform the sorted array back into the original e.g. {1,3,5,2,} -> {1,2,3,5} a = [1,4,2,3].
	 * @param a
	 * @return
	 */
	public static int[] sort(double[] a)
	{
		int[] permut = new int[a.length];
		
		for(int i=0; i< permut.length; i++)
		{
			permut[i] = i+1;
		}
		
		quicksort(0, a.length-1, a, permut);
		
		return permut;
	}
	
	public static void quicksort(int l, int r, double[] a, int[] p)
	{
		if(l < r)
		{
			int div = divide(l, r, a, p);
			quicksort(l, div-1, a, p);
			quicksort(div+1, r, a, p);
		}
	}
	
	public static int[] sort(int[] a)
	{
		int[] permut = new int[a.length];
		
		for(int i=0; i< permut.length; i++)
		{
			permut[i] = i+1;
		}
		
		quicksort(0, a.length-1, a, permut);
		
		return permut;
	}
	
	public static void quicksort(int l, int r, int[] a, int[] p)
	{
		if(l < r)
		{
			int div = divide(l, r, a, p);
			quicksort(l, div-1, a, p);
			quicksort(div+1, r, a, p);
		}
	}
	
	public static int[] revers(int[] a)
	{
		int[] ret_A = new int[a.length];
		
		for(int i=0; i<ret_A.length; i++)
		{
			ret_A[i] = a[a.length-1-i];
		}
		
		return ret_A;
	}
	
	private static int divide(int l, int r, double[] a, int[] p)
	{
		int i = l;
		int j = r-1;
		
		double pivot = a[r];
		
		double help;
		int helpP;
		
		do
		{
			while(a[i] <= pivot && i < r)
			{
				i++;
			}
			while(a[j] >= pivot && l < j)
			{
				j--;
			}
			
			if(i < j)
			{
				help = a[i];
				a[i] = a[j];
				a[j] = help;
				
				helpP = p[i];
				p[i] = p[j];
				p[j] = helpP;
			}
			
			if(a[i] > pivot)
			{
				help = a[i];
				a[i] = a[r];
				a[r] = help;
				
				helpP = p[i];
				p[i] = p[r];
				p[r] = helpP;
			}
		}while(i < j);

		return i;
	}
	
	private static int divide(int l, int r, int[] a, int[] p)
	{
		int i = l;
		int j = r-1;
		
		int pivot = a[r];
		
		int help;
		int helpP;
		
		do
		{
			while(a[i] <= pivot && i < r)
			{
				i++;
			}
			while(a[j] >= pivot && l < j)
			{
				j--;
			}
			
			if(i < j)
			{
				help = a[i];
				a[i] = a[j];
				a[j] = help;
				
				helpP = p[i];
				p[i] = p[j];
				p[j] = helpP;
			}
			
			if(a[i] > pivot)
			{
				help = a[i];
				a[i] = a[r];
				a[r] = help;
				
				helpP = p[i];
				p[i] = p[r];
				p[r] = helpP;
			}
		}while(i < j);

		return i;
	}

}
