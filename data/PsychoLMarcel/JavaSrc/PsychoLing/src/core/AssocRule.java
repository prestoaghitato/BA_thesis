package core;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import core.AssocRuleSet.PatternRule;

public class AssocRule {
	
	public AssocRuleSet ars;
	
	public String premisse;
	
	public HashMap<String, Integer> count_M = new HashMap<>();
	public HashMap<String, Double> duration_M = new HashMap<>();
	
	public double intrest;
	
	public AssocRule(AssocRuleSet ars)
	{
		this.ars = ars;
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
	}
	
	public double confidence(String concl)
	{
		double conf = (double)duration_M.get(concl)/ars.duration_M.get(premisse);
		
		return conf;
	}
	
	public double conclInterest(String concl)
	{
		double interest = (double)duration_M.get(concl)/ars.duration_M.get(concl);
		
		return interest;
	}
	
	public double premiseDuration()
	{	
		return ars.duration_M.get(premisse);
	}
	
	public double conclDuration(String st)
	{
		return this.duration_M.get(st);
	}
	
	/**
	 * Support average Index
	 * @return
	 */
	public double supportAI(String concl)
	{
		return (double)duration_M.get(concl)/ ars.getAvgDuration();
	}
	
	public ArrayList<PatternRule> getPR()
	{
		ArrayList<PatternRule> rule_L = new ArrayList<>();
		PatternRule pr;
		
		StringBuffer sb = new StringBuffer();
		int[] prem = SequenceSet.stringToLabelSet(premisse);
		int[] iA;
		
		//Conclusion
		for(Map.Entry<String, Integer> entry: count_M.entrySet())
		{
			pr = ars.new PatternRule();
			rule_L.add(pr);
			sb = new StringBuffer();
			//Prämisse ------------------------
			sb.append("(");
			for(int i=0; i<prem.length-1; i++)
				sb.append(ars.seqSet.hash_M.get(prem[i]) + ", ");
			sb.append(ars.seqSet.hash_M.get(prem[prem.length-1]) + ")");
				
			pr.premise = sb.toString();
			//----------------------------------
			
			sb = new StringBuffer();
			
			iA = SequenceSet.stringToLabelSet(entry.getKey());
			sb.append("(");
			for(int i=0;i<iA.length-1; i++)
				sb.append(ars.seqSet.hash_M.get(iA[i]) + ", ");
			
			sb.append(ars.seqSet.hash_M.get(iA[iA.length-1]) + ")");
			
			pr.concl 		= sb.toString();
			pr.conf 		= confidence(entry.getKey());
			pr.count 		= entry.getValue();
			pr.duration 	= conclDuration(entry.getKey());
			
		}
		
		return rule_L;
	}
	
	public String printFilter(double conf, double CI, double SAI)
	{		
			StringBuffer sb = new StringBuffer();
		
			int[] prem = SequenceSet.stringToLabelSet(premisse);
			int[] iA;
			
			boolean isFiltered = true;
			
			//Conclusion
			for(Map.Entry<String, Integer> entry: count_M.entrySet())
			{
				if(confidence(entry.getKey()) >= conf
						&& conclInterest(entry.getKey()) >= CI
						&& supportAI(entry.getKey()) >= SAI)
				{
					//Prämisse ------------------------
					sb.append("(");
					for(int i=0; i<prem.length-1; i++)
						sb.append(ars.seqSet.hash_M.get(prem[i]) + ",");
					
					sb.append(ars.seqSet.hash_M.get(prem[prem.length-1]) + ")" + " " + ars.count_M.get(premisse) + " " + FormatUtil.cutDecimal(premiseDuration(),3) + " ");
					//----------------------------------
					
					iA = SequenceSet.stringToLabelSet(entry.getKey());
					sb.append("(");
					for(int i=0;i<iA.length-1; i++)
						sb.append(ars.seqSet.hash_M.get(iA[i]) + ",");
					
					sb.append(ars.seqSet.hash_M.get(iA[iA.length-1]) + ")" + " " + entry.getValue() + " " + FormatUtil.cutDecimal(conclDuration(entry.getKey()),3) + " " + FormatUtil.cutDecimal(confidence(entry.getKey()),3) + " " + FormatUtil.cutDecimal(conclInterest(entry.getKey()),3) + " " + FormatUtil.cutDecimal(supportAI(entry.getKey()),3) + "\n");
					
					isFiltered = false;
				}
			}
			
			if(!isFiltered)
				sb.append("\n");
			
			return sb.toString();
	}

	public String toString()
	{
		StringBuffer sb = new StringBuffer();
		
		int[] prem = SequenceSet.stringToLabelSet(premisse);
		int[] iA;
		
		//Conclusion
		for(Map.Entry<String, Integer> entry: count_M.entrySet())
		{
			//Prämisse ------------------------
			sb.append("(");
			for(int i=0; i<prem.length-1; i++)
				sb.append(ars.seqSet.hash_M.get(prem[i]) + ", ");
			
			sb.append(ars.seqSet.hash_M.get(prem[prem.length-1]) + ")" + " " + ars.count_M.get(premisse) + " " + premiseDuration() + " ");
			//----------------------------------
			
			iA = SequenceSet.stringToLabelSet(entry.getKey());
			sb.append("(");
			for(int i=0;i<iA.length-1; i++)
				sb.append(ars.seqSet.hash_M.get(iA[i]) + ", ");
			
			sb.append(ars.seqSet.hash_M.get(iA[iA.length-1]) + ")" + " " + entry.getValue() + " " + conclDuration(entry.getKey()) + " " + confidence(entry.getKey()) + " " + conclInterest(entry.getKey()) + " " + supportAI(entry.getKey()) + "\n");
		}
		
		return sb.toString();
	}

}
