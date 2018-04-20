package core;

import java.util.ArrayList;

public class Sequence {
	
	ArrayList<int[]> seg_L;
	ArrayList<double[]> duration;
	
	public SequenceSet seqSet;
	
	public Sequence()
	{
		this.seg_L 	= new ArrayList<>();
		this.duration =new ArrayList<>();
	}
	
	public void addSequenceSet(SequenceSet seqSet)
	{
		this.seqSet = seqSet;
	}
	
	public void addSegment(ArrayList<Integer> seg, double[] duration)
	{
		int[] seg_A = new int[seg.size()];
		
		for(int i=0; i<seg.size(); i++)
		{
			seg_A[i] = seg.get(i);
		}
		seg_L.add(seg_A);
		this.duration.add(duration);
	}
	
	public void addSegment(int[] seg)
	{
		seg_L.add(seg);
	}
	
	public ArrayList<Sequence> fragment(int wz, int shiftOff)
	{
		ArrayList<Sequence> ret_L = new ArrayList<>();
		Sequence nSeq;
		
		for(int i=0; i<seg_L.size()-wz; i = i+shiftOff)
		{
			nSeq = new Sequence();
			
			for(int j=0; j<wz; j++)
			{
				nSeq.addSegment(seg_L.get(i+j));
			}
		}
		
		return ret_L;
	}
	
	public String toStringSPMF()
	{
		StringBuffer sb = new StringBuffer();
		
		for(int[] iA: seg_L)
		{
			for(int i=0; i<iA.length; i++)
			{
				sb.append(iA[i] + " ");
			}
			sb.append("-1 ");
		}
		sb.append("-2");
		
		return sb.toString();
	}
	
	public String toStringLabel()
	{
		StringBuffer sb = new StringBuffer();
		
		sb.append("<");
		for(int[] iA: seg_L)
		{
			sb.append("(");
			for(int i=0; i<iA.length-1; i++)
			{
				sb.append(seqSet.getLabel(iA[i]) + ",");
			}

			sb.append(seqSet.getLabel(iA[iA.length-1]) + ")");
		}
		sb.append(">");
		
		return sb.toString();
	}
	
	@Override
	public String toString()
	{	
		StringBuffer sb = new StringBuffer();
		
		sb.append("<");
		for(int j=0; j<seg_L.size(); j++)
		{
			sb.append("(");
			for(int i=0; i<seg_L.get(j).length-1; i++)
			{
				sb.append(seg_L.get(j)[i] + ",");
			}

			sb.append(seg_L.get(j)[seg_L.get(j).length-1] + "[" + duration.get(j)[0] + "," + duration.get(j)[1] + "]" + ")");
		}
		sb.append(">");
		
		return sb.toString();
	}

}
