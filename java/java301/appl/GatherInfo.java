import java.io.IOException;
import java.lang.management.MemoryUsage;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXServiceURL;
import javax.management.*;
import javax.management.openmbean.CompositeData;

public class GatherInfo {

    public static void main(String[] args) throws Exception {
        try {

        String hostName="192.168.56.29";

        String port="12345";

        String urlPath = "service:jmx:rmi:///jndi/rmi://" + hostName + ":" + port + "/jmxrmi";

        JMXServiceURL url = new JMXServiceURL(urlPath);

        JMXConnector conn = JMXConnectorFactory.connect(url);

        MBeanServerConnection server = conn.getMBeanServerConnection();

        ObjectName mxThr = new ObjectName("java.lang:type=Threading");
        ObjectName mxMem = new ObjectName("java.lang:type=Memory");

        String ThreadCount = server.getAttribute(mxThr,"ThreadCount").toString();
        String PeakThreadCount = server.getAttribute(mxThr,"PeakThreadCount").toString();

        CompositeData Heap = (CompositeData) server.getAttribute(mxMem, "HeapMemoryUsage");
        int mb=1024*1024;

        System.out.println("Number of Threads: \t" + ThreadCount );
        System.out.println("Init Heap Memory: \t" + Integer.parseInt(Heap.get("init").toString())/mb + "M");
        System.out.println("Used Heap Memory: \t" + Integer.parseInt(Heap.get("used").toString())/mb + "M");
        System.out.println("Commited Heap Memory: \t" + Integer.parseInt(Heap.get("committed").toString())/mb + "M");
        System.out.println("Max Heap Memory: \t" + Integer.parseInt(Heap.get("max").toString())/mb + "M");

        conn.close();
        }
        catch (  Exception e) {
            e.printStackTrace();
        }
    

    }
}
