package id.my.hendisantika.loanservice.config;

import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * Created by IntelliJ IDEA.
 * Project : spring-boot-observability
 * User: hendisantika
 * Email: hendisantika@gmail.com
 * Telegram : @hendisantika34
 * Date: 04/01/25
 * Time: 08.35
 * To change this template use File | Settings | File Templates.
 */
@Configuration
public class RestClientConfig {

    @Bean
    RestTemplate fraudServiceRestTemplate(RestTemplateBuilder restTemplateBuilder) {
        return restTemplateBuilder
                .rootUri("http://localhost:8081")
                .build();
    }
}
