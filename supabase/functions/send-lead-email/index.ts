import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { name, email, phone, message, productName } = await req.json()

  const TENANT_ID = Deno.env.get('AZURE_TENANT_ID')
  const CLIENT_ID = Deno.env.get('AZURE_CLIENT_ID')
  const CLIENT_SECRET = Deno.env.get('AZURE_CLIENT_SECRET')
  const SENDER_EMAIL = Deno.env.get('AZURE_SENDER_EMAIL') // e.g. biuro@nkodaeurope.com

  try {
    // 1. Pobranie Access Tokena z Microsoft Identity Platform
    const tokenResponse = await fetch(`https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: CLIENT_ID!,
        scope: 'https://graph.microsoft.com/.default',
        client_secret: CLIENT_SECRET!,
        grant_type: 'client_credentials',
      }),
    })

    const tokenData = await tokenResponse.json()
    if (!tokenResponse.ok) throw new Error(`Błąd tokena: ${JSON.stringify(tokenData)}`)
    
    const accessToken = tokenData.access_token

    // 2. Wysyłka e-maila przez Microsoft Graph API
    const sendMailUrl = `https://graph.microsoft.com/v1.0/users/${SENDER_EMAIL}/sendMail`
    
    const emailPayload = {
      message: {
        subject: `Nowe zapytanie o produkt: ${productName}`,
        body: {
          contentType: "HTML",
          content: `
            <div style="font-family: sans-serif; padding: 20px; color: #333;">
              <h1 style="color: #e31e24;">Nowe zapytanie: ${productName}</h1>
              <p><strong>Imię/Firma:</strong> ${name}</p>
              <p><strong>E-mail:</strong> ${email}</p>
              <p><strong>Telefon:</strong> ${phone}</p>
              <br>
              <div style="background: #f4f4f4; padding: 15px; border-radius: 8px;">
                <p><strong>Szczegóły:</strong></p>
                <p style="white-space: pre-wrap;">${message}</p>
              </div>
              <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
              <p style="font-size: 12px; color: #999;">Wysłano z aplikacji NKODA Europe (Wersja Beta)</p>
            </div>
          `
        },
        toRecipients: [
          {
            emailAddress: {
              address: "ppf@nkodaeurope.com"
            }
          }
        ]
      }
    }

    const res = await fetch(sendMailUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailPayload),
    })

    if (res.ok) {
      return new Response(JSON.stringify({ success: true }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200
      })
    } else {
      const errorData = await res.json()
      return new Response(JSON.stringify(errorData), {
        headers: { 'Content-Type': 'application/json' },
        status: 500
      })
    }

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500
    })
  }
})
