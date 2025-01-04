package id.my.hendisantika.loanservice.client;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

/**
 * Created by IntelliJ IDEA.
 * Project : spring-boot-observability
 * User: hendisantika
 * Email: hendisantika@gmail.com
 * Telegram : @hendisantika34
 * Date: 04/01/25
 * Time: 08.34
 * To change this template use File | Settings | File Templates.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class FraudDetectionClient {

    private final RestTemplate fraudServiceRestTemplate;

    public LoanStatus evaluateLoan(int customerId) {
        log.info("Calling Fraud Detection Service for customer id: {}", customerId);
        var response = fraudServiceRestTemplate.exchange("/fraud/check?customerId=" + customerId,
                        HttpMethod.GET, null, LoanStatus.class)
                .getBody();
        log.info("Fraud Detection Service response: {}", response);
        return response;
    }
}
