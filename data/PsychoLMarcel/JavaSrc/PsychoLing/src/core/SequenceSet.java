package core;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

public class SequenceSet {
	
	private int labelCount = 0;

	public ArrayList<Sequence> seq_L;
	public HashMap<Integer,String> hash_M;  //Label
	public HashMap<String,Integer> hash_M_R;
	
	public SequenceSet()
	{
		seq_L = new ArrayList<>();
		hash_M = new HashMap<>();
		hash_M_R = new HashMap<>();
	}
	
	public void buildSequence(ArrayList<String[]> rawS)
	{
		String[] label = new String[rawS.size() * 2];
		double[] timeP = new double[rawS.size() * 2];
		
		int count = 0;
		for(int i=0; i<rawS.size(); i++)
		{
			label[count] = rawS.get(i)[0] + "#S";
			label[count+1] = rawS.get(i)[0] + "#E";
			
			timeP[count] = Double.parseDouble(rawS.get(i)[1]);
			timeP[count+1] = Double.parseDouble(rawS.get(i)[2]);
			
			count = count + 2;
		}
		
		int[] permBack = ArrayUtil.sort(timeP);
		
		String[] sortedLabel = new String[label.length];
		
		for(int i=0; i<permBack.length; i++)
		{
			sortedLabel[i] = label[permBack[i]-1];
		}
		
		//new LabelSet
		ArrayList<Integer> labelSet = new ArrayList<>();
		String[] split;
		
		double currTime = Integer.MIN_VALUE;
		
		Sequence seq = this.getNewSeq();
		
		for(int i=0; i<timeP.length-1; i++)
		{
			currTime = timeP[i];
			
			split = sortedLabel[i].split("#");
			
			if(split[1].equals("S"))
			{
				labelSet.add(this.putLabel(split[0]));
				
				if(currTime !=timeP[i+1]){
					seq.addSegment(labelSet, new double[]{currTime, timeP[i+1]});
				}					
			}
			else
			{
				int labelI = this.putLabel(split[0]);
				labelSet.remove(new Integer(labelI));
				
				if(currTime !=timeP[i+1]){
					seq.addSegment(labelSet, new double[]{currTime, timeP[i+1]});
				}
			}		
		}
	}
	
	public String getLabel(int nL)
	{
		return hash_M.get(nL);
	}
	
	public int putLabel(String rawLabel)
	{
		if(hash_M_R.containsKey(rawLabel))
		{
			return hash_M_R.get(rawLabel);
		}
		else
		{
			hash_M_R.put(rawLabel, ++labelCount);
			hash_M.put(labelCount, rawLabel);
			return labelCount;
		}
	}
	
	public AssocRuleSet buildAssocRules()
	{
		AssocRuleSet ars = new AssocRuleSet(this);
		
		HashSet<String> running_S = new HashSet<>();
		HashSet<String> runningRules = new HashSet<>();
		HashSet<String> runningRulesN = new HashSet<>();
		
		ArrayList<String> oldL = new ArrayList<>();
		ArrayList<String> newL = new ArrayList<>();
						
		ArrayList<String> smashedLabel;
		double duration;
		
		for(Sequence seq: seq_L)
		{
			for(int i=0; i<seq.seg_L.size(); i++)
			{
				smashedLabel 	= smashLabelSet(seq.seg_L.get(i));
				duration 		= seq.duration.get(i)[1] - seq.duration.get(i)[0];
			
				oldL.clear();
				newL.clear();
				
				for(String st: smashedLabel)
				{
					if(!running_S.contains(st))
					{
						ars.putToCount(st);
						newL.add(st);
					}
					else oldL.add(st);
				}
			
				for(String st: newL)
				{
					for(String s2: newL)
					{
						if(!this.labelSCutS2(st, s2))
						{
							ars.putToRule(st, s2, duration);
							runningRulesN.add(st + "b" +s2);
						}						
					}
					ars.putToDuration(st, duration);
				}
				
				for(String st: oldL)
				{
					for(String s2: newL)
						if(!this.labelSCutS2(st, s2))
						{
							ars.putToRule(st, s2, duration);
							runningRulesN.add(st + "b" +s2);
						}
					
					for(String s2: oldL)
					{
						if(!this.labelSCutS2(st, s2))
						{
							if(runningRules.contains(st + "b" +s2))
							{
								runningRulesN.add(st + "b" +s2);
								ars.putToRuleDuration(st,s2,duration);
							}
						}
					}
					
					ars.putToDuration(st, duration);
				}					
				running_S.clear();
				for(String st: smashedLabel)
					running_S.add(st);
				
				runningRules.addAll(runningRulesN);
				runningRulesN.clear();
			}
		}
		
		return ars;
	}
	
	private boolean labelSCutS2(String s1, String s2)
	{
		String[] s1_A = s1.split("a");
		String[] s2_A = s2.split("a");
		
		for(int i=0; i<s1_A.length; i++)
		{
			for(int j=0; j<s2_A.length; j++)
			{
				if(s1_A[i].equals(s2_A[j]))
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	private ArrayList<String> smashLabelSet(int[] labelS)
	{
		ArrayList<String> ret_L = new ArrayList<>();	
		ArrayList<int[][]> pSet = ArrayUtil.powerSet(labelS);
		
		for(int[][] iAA: pSet)
		{
			for(int[] iA: iAA)
			{
				ret_L.add(labelSetToString(iA));
			}
		}
		return ret_L;
	}
	
	public static String labelSetToString(int[] labelS)
	{
		ArrayUtil.sort(labelS);
		
		StringBuffer sb = new StringBuffer();
		
		for(int i=0; i<labelS.length-1; i++)
		{
			sb.append(labelS[i] + "a");
		}
		sb.append(labelS[labelS.length-1]);
		
		return sb.toString();
	}
	
	public static int[] stringToLabelSet(String st)
	{
		String[] split_A = st.split("a");
		
		int[] ret_A = new int[split_A.length];
		
		for(int i=0; i<ret_A.length; i++)
		{
			ret_A[i] = Integer.parseInt(split_A[i]);
		}
		
		return ret_A;
	}
	
	public Sequence getNewSeq()
	{
		Sequence seq = new Sequence();
		seq.addSequenceSet(this);
		this.seq_L.add(seq);
		
		return seq;
	}
	
	public String toStringSPMF()
	{
		StringBuffer sb = new StringBuffer();
		
		for(Sequence seq: seq_L)
		{
			sb.append(seq.toStringSPMF() + "\n");
		}
		
		return sb.toString();
	}
	
	public String toStringLabel()
	{
		StringBuffer sb = new StringBuffer();
		
		for(Sequence seq: seq_L)
		{
			sb.append(seq.toStringLabel() + "\n");
		}
		
		return sb.toString();
	}
	
	public String toString()
	{
		StringBuffer sb = new StringBuffer();
		
		for(Sequence seq: seq_L)
		{
			sb.append(seq.toString() + "\n");
		}
		
		return sb.toString();
	}
	
	public String toStringTable()
	{
		StringBuffer sb = new StringBuffer();
		
		for(Map.Entry<Integer, String> e: hash_M.entrySet())
		{
			sb.append(e.getKey() + "\t\t" + e.getValue() + "\n");
		}
		
		
		return sb.toString();
	}
}
