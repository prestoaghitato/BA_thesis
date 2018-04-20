package core;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeSet;


public class AssocRuleSet {
	
	HashMap<String, AssocRule> 	aRule_M = new HashMap<>(); 	
	HashMap<String, Integer> 	count_M = new HashMap<>();
	HashMap<String, Double> 	duration_M = new HashMap<>();
	
	SequenceSet seqSet;
	
	int allCount = 0;
	double allDuration = 0;
	
	public AssocRuleSet(SequenceSet seqSet)
	{
		this.seqSet = seqSet;
	}
	
	public void putToCount(String st)
	{
		if(count_M.containsKey(st))
		{
			count_M.put(st, count_M.get(st) + 1);
		}
		else
		{
			count_M.put(st, 1);
		}
		allCount++;
	}
	
	public void putToDuration(String st, double du)
	{
		if(duration_M.containsKey(st))
		{
			duration_M.put(st, duration_M.get(st) + du);
		}
		else
		{
			duration_M.put(st, du);
		}
		allDuration = allDuration + du;
	}
	
	public void putToRuleDuration(String rule, String add, double duration)
	{
		aRule_M.get(rule).putToDuration(add, duration);
	}
	
	public void putToRule(String rule, String add, double duration)
	{
		if(aRule_M.containsKey(rule))
		{
			aRule_M.get(rule).putToCount(add);
			aRule_M.get(rule).putToDuration(add, duration);
		}
		else
		{
			AssocRule ar = new AssocRule(this);
			ar.premisse = rule;
			ar.putToCount(add);
			ar.putToDuration(add, duration);
			aRule_M.put(rule, ar);
		}
	}
	
	public double getAvgCount()
	{
		return allCount/(double)count_M.size();
	}
	
	public double getAvgDuration()
	{
		return allDuration/(double)count_M.size();
	}
	
	public String printFilter(double conf, double CI, double SAI)
	{	
		StringBuffer sb = new StringBuffer();
		sb.append("PREMISE freq(PREMISE) d(PREMISE) CONCLUSION freq(RULE) d(Rule) Confidence CI SAI \n");
		
		for(Map.Entry<String, AssocRule> entry: aRule_M.entrySet())
		{		
				sb.append(entry.getValue().printFilter(conf, CI, SAI));
		}
		
		return sb.toString();
	}
	
	public String toString()
	{
		StringBuffer sb = new StringBuffer();
		
		sb.append("premise afrequnecy conclusion confidence CI SAI \n");
		
		for(Map.Entry<String, AssocRule> entry: aRule_M.entrySet())
		{
			sb.append(entry.getValue().toString() + "\n");
		}	
		return sb.toString();
	}
	
	public String rulesToString()
	{
		StringBuffer sb = new StringBuffer();
		TreeSet<PatternRule> ts = new TreeSet<>();
		
		int pString = 0;
		int cString = 0;
		
		double minConf = 0.1;
		
		for(Map.Entry<String, AssocRule> entry: aRule_M.entrySet())
		{;
			for(PatternRule pr: entry.getValue().getPR())
			{
				if(pr.conf >= minConf)
				{
					if(pString < pr.premise.length()) 	pString = pr.premise.length();
					if(cString < pr.concl.length()) 	cString = pr.concl.length();
				}
			}

			ts.addAll(entry.getValue().getPR());
		}
		
		for(PatternRule pr: ts)
		{
			if(pr.conf >= minConf)
			{
				int digCf = (FormatUtil.cutDecimal(pr.conf,3)+"").length();
				int digCo = (pr.count + "").length();
				sb.append(pr.premise
						+ String.format("%" + (pString - pr.premise.length() + 1) + "s", "")
						+ pr.concl
						+ String.format("%" + (cString - pr.concl.length() + 1) + "s", "")
						+ FormatUtil.cutDecimal(pr.conf,3)
						+ String.format("%" + (5 - digCf + 1) + "s", "")
						+ pr.count
						+ String.format("%" + (5 - digCo + 1) + "s", "")
						+ FormatUtil.cutDecimal(pr.duration,3) + "\n");
			}
		}
		
		return sb.toString();
	}
	
	public String countAndDuration()
	{
		StringBuffer sb = new StringBuffer();
		
		TreeSet<PatternSet> ts = new TreeSet<>();
		int[] iA;
		int lString = 0;
		int currString = 0;
		String label;
		
		for(Map.Entry<String, Integer> entry: count_M.entrySet())
		{
			iA = SequenceSet.stringToLabelSet(entry.getKey());
			
			//how long is the String
			currString = 0;
			for(int i=0;i<iA.length; i++)
			{
				currString = currString + (seqSet.hash_M.get(iA[i])).length() + 2;
			}
			if(currString > lString) lString = currString;
			
			ts.add(new PatternSet(iA, entry.getValue(), duration_M.get(entry.getKey())));
		}
		
		for(PatternSet ps: ts)
		{
			sb.append("(");
			currString = 0;
			for(int i=0;i<ps.pattern.length-1; i++)
			{
				label = seqSet.hash_M.get(ps.pattern[i]);
				sb.append(label + ", ");
				currString = currString + label.length() + 2;
			}
			
			label = seqSet.hash_M.get(ps.pattern[ps.pattern.length-1]);
			currString = currString + label.length();
			
			sb.append(label + ")" + String.format("%" + (lString - currString + 1) + "s","") + ps.count + " \t" + FormatUtil.cutDecimal(ps.duration,3) + "\n");
		}
		
		return sb.toString();
	}
	
	private class PatternSet implements Comparable<PatternSet>
	{
		int[] pattern; // pattern
		int count;
		double duration;

		public PatternSet(int[] iA, int count, double duration)
		{
			this.pattern 		= iA;
			this.count 		= count;
			this.duration 	= duration;
		}

		@Override
		public int compareTo(PatternSet ob2) {
			
			if(this.count > ob2.count) return-1;
			else return 1;
		}
	}
	
	public class PatternRule implements Comparable<PatternRule>
	{
		String premise;
		String concl;
		
		double conf;
		int count;
		double duration;

		@Override
		public int compareTo(PatternRule ob2) {
			
			if(this.conf > ob2.conf) return-1;
			else return 1;
		}
	}

}
